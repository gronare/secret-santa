class WishlistReadyNotificationJob < ApplicationJob
  queue_as :default

  def perform(participant_id, token)
    participant = Participant.find_by(id: participant_id)
    return unless participant
    return unless participant.wishlist_items.exists?
    return unless participant.wishlist_update_notification_token == token

    gifter = participant.gifter
    return unless gifter

    ParticipantMailer.wishlist_ready(gifter, participant).deliver_later

    participant.update!(
      wishlist_update_notified_at: Time.current,
      wishlist_update_notification_token: nil,
      wishlist_update_notification_scheduled_at: nil
    )
  end
end
