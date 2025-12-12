require "test_helper"

class WishlistReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends reminder when token matches and wishlist is empty" do
    participant = participants(:carol)
    token = SecureRandom.uuid

    participant.update!(
      wishlist_empty_reminder_token: token,
      wishlist_empty_reminder_scheduled_at: 1.day.from_now
    )

    assert_emails 1 do
      WishlistReminderJob.perform_now(participant.id, token)
    end

    participant.reload
    assert_nil participant.wishlist_empty_reminder_token
    assert_nil participant.wishlist_empty_reminder_scheduled_at
    assert_not_nil participant.wishlist_empty_reminded_at
  end

  test "skips reminder if wishlist exists" do
    participant = participants(:carol)
    participant.wishlist_items.create!(description: "Board game")

    assert_no_emails do
      WishlistReminderJob.perform_now(participant.id, SecureRandom.uuid)
    end
  end
end
