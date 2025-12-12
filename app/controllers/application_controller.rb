class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # HEY/Basecamp pattern: Set Current attributes for request-scoped data
  before_action :set_current_attributes
  before_action :authenticate_with_magic_token
  before_action :set_current_participant, if: :participant_session?

  private

  def set_current_attributes
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
  end

  def set_current_participant
    Current.participant = Participant.find_by(id: session[:participant_id])
  end

  def participant_session?
    session[:participant_id].present?
  end

  # Allows magic-link deep links to specific resources (e.g., wishlist)
  # Only authenticates when both token and participant_id are present and belong together.
  def authenticate_with_magic_token
    token = params[:magic_token]
    participant_id = params[:participant_id]
    return if token.blank? || participant_id.blank?

    user = User.find_by_token_for(:magic_link, token)
    return unless user

    participant = user.participants.find_by(id: participant_id)
    return unless participant

    reset_session
    session[:user_id] = user.id
    session[:participant_id] = participant.id
    Current.participant = participant
  end

  # HEY pattern: No helper wrappers, access Current directly in views
  def require_participant!
    unless Current.participant
      redirect_to root_path, alert: "Please log in to continue"
    end
  end

  # Prevent modifications to active or completed events
  def prevent_if_active
    if @event&.active? || @event&.completed?
      redirect_to organize_event_path(@event), alert: "Cannot modify an active or completed event."
    end
  end
end
