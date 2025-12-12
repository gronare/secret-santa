namespace :wishlist do
  desc "Schedule wishlist reminders for all active events (useful after deploy)"
  task schedule_reminders: :environment do
    events = Event.active
    Rails.logger.info "Scheduling wishlist reminders and ready notifications for #{events.count} active event(s)..."

    events.find_each do |event|
      WishlistNotificationService.schedule_reminders_for_event!(event)
      WishlistNotificationService.schedule_ready_notifications_for_event!(event, delay: 15.minutes)
      Rails.logger.info "Queued empty-wishlist reminders and ready notices for event #{event.id} (#{event.name})"
    end

    Rails.logger.info "Done scheduling wishlist reminders."
  end
end
