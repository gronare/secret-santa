class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :organize ]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      # Create organizer as first participant
      @event.participants.create!(
        name: @event.organizer_name,
        email: @event.organizer_email,
        is_organizer: true
      )

      redirect_to organize_event_path(@event), notice: "Event created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @participant = @event.participants.find_by(id: session[:participant_id])
  end

  def organize
    @participants = @event.participants.order(created_at: :asc)
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(
      :name,
      :event_date,
      :location,
      :budget,
      :description,
      :organizer_name,
      :organizer_email
    )
  end
end
