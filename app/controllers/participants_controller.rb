class ParticipantsController < ApplicationController
  before_action :set_event
  before_action :require_organizer

  def create
    # Find or create user for this email
    user = User.find_or_create_by!(email: participant_params[:email])

    # Build participant with user
    @participant = @event.participants.build(participant_params.merge(user: user))

    if @participant.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organize_event_path(@event), notice: "Participant added successfully!" }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("participant_form",
            partial: "participants/form",
            locals: { event: @event, participant: @participant })
        }
        format.html { redirect_to organize_event_path(@event), alert: "Failed to add participant." }
      end
    end
  end

  def destroy
    @participant = @event.participants.find(params[:id])
    @participant.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organize_event_path(@event), notice: "Participant removed." }
    end
  end

  private

  def require_organizer
    unless Current.participant&.organizer? && Current.participant.event_id == @event.id
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
    Current.event = @event
  end

  def participant_params
    params.require(:participant).permit(:name, :email)
  end
end
