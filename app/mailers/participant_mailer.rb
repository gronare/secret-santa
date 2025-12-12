class ParticipantMailer < ApplicationMailer
  default from: "Secret Santa <noreply@secretsanta.gronare.com>"

  def invitation(participant)
    @participant = participant
    @event = participant.event
    @magic_link = auth_url(participant.user.generate_token_for(:magic_link))

    mail(
      to: @participant.email,
      subject: "You're invited to #{@event.name}!"
    )
  end

  def assignment(participant)
    @participant = participant
    @event = participant.event
    @assigned_person = participant.assigned_participant
    @magic_link = auth_url(participant.user.generate_token_for(:magic_link))

    mail(
      to: @participant.email,
      subject: "Your Secret Santa assignment for #{@event.name}"
    )
  end

  def wishlist_ready(gifter, giftee)
    @participant = gifter
    @giftee = giftee
    @event = giftee.event
    @magic_link = event_url(@event, magic_token: gifter.user.generate_token_for(:magic_link), participant_id: gifter.id)

    mail(
      to: gifter.email,
      subject: "#{@giftee.name} updated their wishlist for #{@event.name}"
    )
  end

  def wishlist_reminder(participant)
    @participant = participant
    @event = participant.event
    @magic_link = wishlist_items_url(magic_token: participant.user.generate_token_for(:magic_link), participant_id: participant.id)

    mail(
      to: participant.email,
      subject: "Add your wishlist for #{@event.name}"
    )
  end
end
