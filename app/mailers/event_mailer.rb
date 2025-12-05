class EventMailer < ApplicationMailer
  default from: "Secret Santa <noreply@secretsanta.gronare.com>"

  def organizer_welcome(event)
    @event = event
    @magic_link = auth_url(@event.generate_token_for(:organizer_access))

    mail(
      to: @event.organizer_email,
      subject: "Your Secret Santa Event: #{@event.name}"
    )
  end
end
