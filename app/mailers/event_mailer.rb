class EventMailer < ApplicationMailer
  default from: "Secret Santa <noreply@secretsanta.gronare.com>"

  def organizer_welcome(event)
    @event = event
    @organizer = event.organizer
    @magic_link = auth_url(@organizer.user.generate_token_for(:magic_link))

    mail(
      to: @event.organizer_email,
      subject: "Your Secret Santa Event: #{@event.name}"
    )
  end
end
