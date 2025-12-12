# Schedules wishlist-related notifications and reminders
class WishlistNotificationService
  READY_EMAIL_DELAY = 3.hours
  REMINDER_FALLBACK_DELAY = 3.days

  class << self
    # Notify the gifter after a short delay when a wishlist item is added
    def schedule_ready_notification_after_change!(participant)
      return unless participant&.event&.active?
      return unless participant.wishlist_items.exists?

      gifter = participant.gifter
      return unless gifter

      now = Time.current

      # If a notification is already queued, keep it (prevents multiple emails within the delay window)
      if participant.wishlist_update_notification_scheduled_at&.>(now)
        return
      end

      token = SecureRandom.uuid
      send_at = now + READY_EMAIL_DELAY

      participant.update!(
        wishlist_update_notification_token: token,
        wishlist_update_notification_scheduled_at: send_at
      )

      WishlistReadyNotificationJob.set(wait_until: send_at).perform_later(participant.id, token)

      cancel_pending_empty_reminder!(participant)
    end

    # Schedule reminders for participants with empty wishlists
    def schedule_reminders_for_event!(event)
      return unless event&.active?

      send_at = [ reminder_time_for(event), 15.minutes.from_now ].max

      event.participants.with_assignments.find_each do |participant|
        next if participant.wishlist_items.exists?
        next if participant.wishlist_empty_reminded_at.present?
        next if participant.wishlist_empty_reminder_scheduled_at&.>(Time.current)

        token = SecureRandom.uuid
        participant.update!(
          wishlist_empty_reminder_token: token,
          wishlist_empty_reminder_scheduled_at: send_at
        )

        WishlistReminderJob.set(wait_until: send_at).perform_later(participant.id, token)
      end
    end

    # Backfill ready notifications for participants who already added wishlist items
    def schedule_ready_notifications_for_event!(event, delay: READY_EMAIL_DELAY)
      return unless event&.active?

      send_at = [ Time.current + delay, 15.minutes.from_now ].max

      event.participants.includes(:wishlist_items).find_each do |participant|
        next unless participant.wishlist_items.exists?

        gifter = participant.gifter
        next unless gifter

        next if participant.wishlist_update_notified_at.present?
        next if participant.wishlist_update_notification_scheduled_at&.>(Time.current)

        token = SecureRandom.uuid
        participant.update!(
          wishlist_update_notification_token: token,
          wishlist_update_notification_scheduled_at: send_at
        )

        WishlistReadyNotificationJob.set(wait_until: send_at).perform_later(participant.id, token)

        cancel_pending_empty_reminder!(participant)
      end
    end

    def reminder_time_for(event)
      base_time = event.launched_at || event.created_at || Time.current

      if event.event_date.present?
        interval = event.event_date.to_time - base_time
        delay = interval.positive? ? interval / 3.0 : REMINDER_FALLBACK_DELAY
      else
        delay = REMINDER_FALLBACK_DELAY
      end

      base_time + delay
    end

    def cancel_pending_empty_reminder!(participant)
      return unless participant.wishlist_empty_reminder_scheduled_at.present? || participant.wishlist_empty_reminder_token.present?

      participant.update_columns(
        wishlist_empty_reminder_token: nil,
        wishlist_empty_reminder_scheduled_at: nil
      )
    end
  end
end
