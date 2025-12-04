class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Modern Rails: Set Current attributes for request-scoped data
  before_action :set_current_attributes
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

  def current_participant
    Current.participant
  end
  helper_method :current_participant

  def current_event
    Current.event
  end
  helper_method :current_event

  def require_participant!
    unless current_participant
      redirect_to root_path, alert: "Please log in to continue"
    end
  end
end
