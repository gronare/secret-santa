class EventSettingsController < ApplicationController
  before_action :set_event
  before_action :require_organizer
  before_action :prevent_if_active, only: [ :update ]

  def edit
    # Redirect to dashboard if event is active or completed
    if @event.active? || @event.completed?
      redirect_to dashboard_event_path(@event)
      nil
    end
  end

  def update
    if @event.update(event_settings_params)
      respond_to do |format|
        # Redirect to organize for draft events, dashboard for active events
        redirect_path = @event.active? ? dashboard_event_path(@event) : organize_event_path(@event)
        format.html { redirect_to redirect_path, notice: "Settings saved successfully!" }
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
      :organizer_participates
    )
  end
end
