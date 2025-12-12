class WishlistReminderJob < ApplicationJob
  queue_as :default

  def perform(participant_id, token)
    participant = Participant.find_by(id: participant_id)
    return unless participant
    return if participant.wishlist_items.exists?
    return unless participant.wishlist_empty_reminder_token == token

    ParticipantMailer.wishlist_reminder(participant).deliver_now

    participant.update!(
      wishlist_empty_reminded_at: Time.current,
      wishlist_empty_reminder_token: nil,
      wishlist_empty_reminder_scheduled_at: nil
    )
  end
end
