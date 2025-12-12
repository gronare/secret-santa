require "test_helper"

class WishlistReadyNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "delivers and clears scheduling fields when token matches and wishlist exists" do
    event = events(:christmas_2024)
    event.update!(status: :active)

    giftee = participants(:bob)
    gifter = participants(:alice)
    gifter.update!(assigned_to_id: giftee.id)
    giftee.wishlist_items.create!(description: "Coffee grinder")

    token = SecureRandom.uuid
    giftee.update!(
      wishlist_update_notification_token: token,
      wishlist_update_notification_scheduled_at: 3.hours.from_now
    )

    assert_emails 1 do
      WishlistReadyNotificationJob.perform_now(giftee.id, token)
    end

    giftee.reload
    assert_nil giftee.wishlist_update_notification_token
    assert_nil giftee.wishlist_update_notification_scheduled_at
    assert_not_nil giftee.wishlist_update_notified_at
  end

  test "does nothing when token mismatches" do
    giftee = participants(:bob)
    giftee.wishlist_items.create!(description: "Book")

    assert_no_emails do
      WishlistReadyNotificationJob.perform_now(giftee.id, "wrong-token")
    end
  end
end
