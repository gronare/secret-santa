require "test_helper"

class WishlistNotificationServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @event = events(:christmas_2024)
    @event.update!(status: :active, launched_at: Time.current)

    @giftee = participants(:bob)
    @gifter = participants(:alice)

    # Alice buys for Bob
    @gifter.update!(assigned_to_id: @giftee.id)

    @giftee.wishlist_items.create!(description: "Warm socks")
  end

  test "schedules a single ready notification within delay window" do
    assert_enqueued_jobs 1, only: WishlistReadyNotificationJob do
      WishlistNotificationService.schedule_ready_notification_after_change!(@giftee)
    end

    scheduled_for = @giftee.reload.wishlist_update_notification_scheduled_at
    assert_in_delta 3.hours.from_now, scheduled_for, 5.minutes

    # A second change within the window should not enqueue another job
    assert_enqueued_jobs 0 do
      WishlistNotificationService.schedule_ready_notification_after_change!(@giftee)
    end
  end

  test "re-schedules after previous notification was sent" do
    # Simulate an email already sent
    @giftee.update!(
      wishlist_update_notified_at: 1.day.ago,
      wishlist_update_notification_scheduled_at: nil,
      wishlist_update_notification_token: nil
    )

    assert_enqueued_jobs 1, only: WishlistReadyNotificationJob do
      WishlistNotificationService.schedule_ready_notification_after_change!(@giftee)
    end

    assert @giftee.reload.wishlist_update_notification_token.present?
  end

  test "cancels pending empty reminder when scheduling ready notification" do
    @giftee.update!(
      wishlist_empty_reminder_token: "remind-token",
      wishlist_empty_reminder_scheduled_at: 1.hour.from_now
    )

    assert_enqueued_jobs 1, only: WishlistReadyNotificationJob do
      WishlistNotificationService.schedule_ready_notification_after_change!(@giftee)
    end

    @giftee.reload
    assert_nil @giftee.wishlist_empty_reminder_token
    assert_nil @giftee.wishlist_empty_reminder_scheduled_at
  end

  test "reminders schedule at minimum 15 minutes in the future" do
    travel_to Time.current do
      participant_without_wishlist = participants(:carol)
      participant_without_wishlist.update!(assigned_to_id: @gifter.id)
      @event.update!(event_date: 1.week.ago, launched_at: 1.month.ago)

      assert_enqueued_jobs 1, only: WishlistReminderJob do
        WishlistNotificationService.schedule_reminders_for_event!(@event)
      end

      participant_without_wishlist.reload
      scheduled_at = participant_without_wishlist.wishlist_empty_reminder_scheduled_at
      assert scheduled_at >= 14.minutes.from_now
    end
  end

  test "backfills ready notifications for participants who already have wishlist items" do
    giftee = @giftee
    gifter = @gifter
    gifter.update!(assigned_to_id: giftee.id)

    assert_enqueued_jobs 1, only: WishlistReadyNotificationJob do
      WishlistNotificationService.schedule_ready_notifications_for_event!(@event, delay: 15.minutes)
    end

    giftee.reload
    assert giftee.wishlist_update_notification_token.present?
    assert giftee.wishlist_update_notification_scheduled_at.present?
  end

  test "reminders scheduled for participants with empty wishlists" do
    participant_without_wishlist = participants(:carol)
    participant_without_wishlist.update!(assigned_to_id: @gifter.id)

    assert_enqueued_with(job: WishlistReminderJob) do
      WishlistNotificationService.schedule_reminders_for_event!(@event)
    end

    participant_without_wishlist.reload
    assert participant_without_wishlist.wishlist_empty_reminder_token.present?
    assert participant_without_wishlist.wishlist_empty_reminder_scheduled_at.present?

    # Giftee already has items, should not get reminder
    @giftee.reload
    assert_nil @giftee.wishlist_empty_reminder_token
  end
end
