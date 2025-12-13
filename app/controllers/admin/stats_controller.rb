module Admin
  class StatsController < BaseController
    def show
      @event_counts = {
        total: Event.count,
        draft: Event.draft.count,
        active: Event.active.count,
        completed: Event.completed.count
      }

      @participant_counts = {
        total: Participant.count,
        with_assignments: Participant.where.not(assigned_to_id: nil).count,
        organizers: Participant.where(is_organizer: true).count
      }

      @wishlist_counts = {
        items: WishlistItem.count,
        participants_with_items: Participant.joins(:wishlist_items).distinct.count,
        participants_without_items: Participant.left_outer_joins(:wishlist_items).where(wishlist_items: { id: nil }).distinct.count
      }

      now = Time.current
      activity_scope = Participant.where("COALESCE(last_activity_at, last_sign_in_at) >= ?", now - 7.days)
      @activity_counts = {
        logged_past_hour: activity_scope.where("COALESCE(last_activity_at, last_sign_in_at) >= ?", now - 1.hour).count,
        logged_past_day: activity_scope.where("COALESCE(last_activity_at, last_sign_in_at) >= ?", now - 24.hours).count,
        logged_past_week: activity_scope.count
      }

      @recent_events = Event.order(created_at: :desc).limit(5)

      @queue_counts, @queue_error = queue_counts
    end
  end
end
