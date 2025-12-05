class SessionsController < ApplicationController
  # Modern Rails: Using generates_token_for for magic link authentication
  skip_before_action :set_current_participant, only: [ :new, :create, :authenticate ]

  def new
    # Show email input for magic link
  end

  def create
    @participant = Participant.find_by(email: params[:email]&.strip&.downcase)

    if @participant
      # Modern Rails: generates_token_for creates secure, expiring tokens
      token = @participant.generate_token_for(:magic_link)
      magic_link = auth_url(token)

      # Send magic link via email (will implement mailer next)
      # ParticipantMailer.magic_link(@participant, magic_link).deliver_later

      redirect_to root_path, notice: "Check your email for a magic link to sign in!"
    else
      redirect_to new_session_path, alert: "Email not found. Please check your email address."
    end
  end

  def authenticate
    @participant = Participant.find_by_token_for(:magic_link, params[:token])

    if @participant
      session[:participant_id] = @participant.id
      Current.participant = @participant
      @participant.update_column(:last_sign_in_at, Time.current)

      if @participant.organizer?
        redirect_path = @participant.event.active? ? dashboard_event_path(@participant.event) : organize_event_path(@participant.event)
      else
        redirect_path = event_path(@participant.event)
      end

      redirect_to redirect_path, notice: "Successfully signed in!"
    else
      redirect_to root_path, alert: "Invalid or expired magic link. Please request a new one."
    end
  end

  def destroy
    session.delete(:participant_id)
    Current.participant = nil

    redirect_to root_path, notice: "Successfully signed out!"
  end
end
