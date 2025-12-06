class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :organize, :dashboard, :launch, :draw_assignments, :send_reminder ]
  before_action :require_organizer, only: [ :organize, :dashboard, :launch, :draw_assignments, :send_reminder ]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      # Find or create user for this email
      user = User.find_or_create_by!(email: @event.organizer_email)

      # Create participant for this event
      organizer = @event.participants.create!(
        user: user,
        name: @event.organizer_name,
        email: @event.organizer_email,
        is_organizer: true
      )

      session[:user_id] = user.id
      session[:participant_id] = organizer.id
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

    # Eager load wishlist items for both participant and their assignment
    if @participant
      @participant = @event.participants
        .includes(:wishlist_items, assigned_to: :wishlist_items)
        .find(@participant.id)
    end
  end

  def organize
    @participants = @event.participants.order(created_at: :asc)
  end

  def dashboard
    @participants = @event.participants.order(created_at: :asc)
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

  def require_organizer
    unless Current.participant&.organizer? && Current.participant.event_id == @event.id
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def set_event
    action_name = params[:action].to_sym

    case action_name
    when :dashboard
      @event = Event.includes(participants: :wishlist_items).find_by!(slug: params[:id])
    when :organize, :launch, :send_reminder
      @event = Event.includes(:participants).find_by!(slug: params[:id])
    else
      @event = Event.find_by!(slug: params[:id])
    end

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
