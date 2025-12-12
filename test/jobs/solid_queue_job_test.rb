require "test_helper"

class SolidQueueJobTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :solid_queue
    clear_solid_queue
  end

  teardown do
    clear_solid_queue
    ActiveJob::Base.queue_adapter = @original_adapter
  end

  test "perform_later without delay creates a ready execution" do
    participant = participants(:carol)
    token = "ready-token"

    assert_difference -> { SolidQueue::ReadyExecution.count }, 1 do
      WishlistReminderJob.perform_later(participant.id, token)
    end

    job = SolidQueue::Job.order(:id).last
    assert_equal "WishlistReminderJob", job.class_name
    assert_in_delta Time.current, job.scheduled_at, 1.second
    assert_equal :ready, job.status
  end

  test "perform_later with wait_until creates a scheduled execution" do
    participant = participants(:bob)
    token = "scheduled-token"

    travel_to Time.current do
      assert_difference -> { SolidQueue::ScheduledExecution.count }, 1 do
        WishlistReadyNotificationJob.set(wait_until: 15.minutes.from_now).perform_later(participant.id, token)
      end

      job = SolidQueue::Job.order(:id).last
      assert_equal "WishlistReadyNotificationJob", job.class_name
      assert_in_delta 15.minutes.from_now, job.scheduled_at, 1.second
      assert_equal :scheduled, job.status
    end
  end

  private

  def clear_solid_queue
    SolidQueue::ReadyExecution.delete_all
    SolidQueue::ScheduledExecution.delete_all
    SolidQueue::FailedExecution.delete_all
    SolidQueue::ClaimedExecution.delete_all
    SolidQueue::Job.delete_all
  end
end
