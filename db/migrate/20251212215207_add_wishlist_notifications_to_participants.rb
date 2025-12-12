class AddWishlistNotificationsToParticipants < ActiveRecord::Migration[8.1]
  def change
    change_table :participants, bulk: true do |t|
      t.datetime :wishlist_update_notification_scheduled_at
      t.string :wishlist_update_notification_token
      t.datetime :wishlist_update_notified_at
      t.datetime :wishlist_empty_reminder_scheduled_at
      t.string :wishlist_empty_reminder_token
      t.datetime :wishlist_empty_reminded_at
    end
  end
end
