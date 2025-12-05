class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :organize, :dashboard, :launch, :draw_assignments, :send_reminder ]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      organizer = @event.participants.create!(
        name: @event.organizer_name,
        email: @event.organizer_email,
        is_organizer: true
      )

      Current.participant = organizer
      Current.event = @event

      EventMailer.organizer_welcome(@event).deliver_later

      redirect_to organize_event_path(@event), notice: "Event created! Check your email for the magic link."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # HEY pattern: Access Current directly, no helper method
    @participant = Current.participant
  end

  def organize
    @participants = @event.participants.strict_loading(false).order(created_at: :asc)
  end

  def dashboard
    @participants = @event.participants.includes(:wishlist_items).order(created_at: :asc)
  end

  def send_reminder
    participant = @event.participants.find(params[:participant_id])
    ParticipantMailer.invitation(participant).deliver_later
    participant.update_column(:invitation_sent_at, Time.current)

    redirect_to dashboard_event_path(@event), notice: "Reminder sent to #{participant.name}!"
  end

  def launch
    unless @event.draft?
      redirect_to dashboard_event_path(@event), alert: "Event has already been launched."
      return
    end

    SecretSanta::AssignmentService.new(@event).call
    @event.launch!

    @event.participants.each do |participant|
      participant.update_column(:invitation_sent_at, Time.current)
      ParticipantMailer.invitation(participant).deliver_later
    end

    respond_to do |format|
      format.html { redirect_to dashboard_event_path(@event), notice: "Event launched! Invitations sent to all participants." }
      format.turbo_stream
    end
  rescue SecretSanta::AssignmentService::InsufficientParticipantsError => e
    redirect_to organize_event_path(@event), alert: e.message
  end

  def draw_assignments
    SecretSanta::AssignmentService.new(@event).call

    respond_to do |format|
      format.html { redirect_to organize_event_path(@event), notice: "Assignments reshuffled!" }
      format.turbo_stream
    end
  rescue SecretSanta::AssignmentService::InsufficientParticipantsError => e
    redirect_to organize_event_path(@event), alert: e.message
  end

  private

  def set_event
    # Modern Rails: includes for eager loading associations
    @event = Event.includes(:participants).find_by!(slug: params[:id])
    Current.event = @event
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
