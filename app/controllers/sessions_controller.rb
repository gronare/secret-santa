class SessionsController < ApplicationController
  # Modern Rails: Using generates_token_for for magic link authentication
  skip_before_action :set_current_participant, only: [ :new, :create, :authenticate, :select_event ]

  def new
    # Show email input for magic link
  end

  def create
    email = params[:email]&.strip&.downcase
    user = User.find_by(email: email)

    if user
      # Modern Rails: generates_token_for creates secure, expiring tokens
      token = user.generate_token_for(:magic_link)
      magic_link = auth_url(token)

      # Send magic link via email
      UserMailer.magic_link(user, magic_link).deliver_later

      redirect_to root_path, notice: "Check your email for a magic link to sign in!"
    else
      redirect_to root_path, alert: "Email not found. Please check your email address."
    end
  end

  def authenticate
    @user = User.find_by_token_for(:magic_link, params[:token])

    if @user
      session[:user_id] = @user.id

      # If user has multiple events, show selector
      if @user.participants.count > 1
        @participants = @user.participants.includes(:event).order("events.created_at DESC")
        render :select_event
      else
        # Single event - sign in directly
        participant = @user.participants.first
        sign_in_participant(participant)
      end
    else
      redirect_to root_path, alert: "Invalid or expired magic link. Please request a new one."
    end
  end

  def select_event
    user = User.find(session[:user_id])
    participant = user.participants.find(params[:participant_id])
    sign_in_participant(participant)
  end

  def destroy
    session.delete(:user_id)
    session.delete(:participant_id)
    Current.participant = nil

    redirect_to root_path, notice: "Successfully signed out!"
  end

  private

  def sign_in_participant(participant)
    session[:participant_id] = participant.id
    Current.participant = participant
    participant.update_column(:last_sign_in_at, Time.current)

    if participant.organizer?
      redirect_path = participant.event.active? ? dashboard_event_path(participant.event) : organize_event_path(participant.event)
    else
      redirect_path = event_path(participant.event)
    end

    redirect_to redirect_path, notice: "Successfully signed in!"
  end
end
