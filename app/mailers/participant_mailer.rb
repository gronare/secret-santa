class ParticipantMailer < ApplicationMailer
  default from: "Secret Santa <noreply@secretsanta.gronare.com>"

  def invitation(participant)
    @participant = participant
    @event = participant.event
    @magic_link = auth_url(@participant.generate_token_for(:magic_link))

    mail(
      to: @participant.email,
      subject: "You're invited to #{@event.name}!"
    )
  end

  def assignment(participant)
    @participant = participant
    @event = participant.event
    @assigned_person = participant.assigned_participant
    @magic_link = auth_url(@participant.generate_token_for(:magic_link))

    mail(
      to: @participant.email,
      subject: "Your Secret Santa assignment for #{@event.name}"
    )
  end
end
