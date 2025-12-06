class EventSettingsController < ApplicationController
  before_action :set_event
  before_action :require_organizer

  def edit
  end

  def update
    if @event.update(event_settings_params)
      respond_to do |format|
        format.html { redirect_to organize_event_path(@event), notice: "Settings updated successfully!" }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_organizer
    unless Current.participant&.organizer? && Current.participant.event_id == @event.id
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def set_event
    @event = Event.includes(:participants).find_by!(slug: params[:event_id])
    Current.event = @event
  end

  def event_settings_params
    params.require(:event).permit(
      :theme,
      :custom_message,
      :require_rsvp,
      :require_address,
      :require_wishlist,
      :organizer_participates
    )
  end
end
