module Admin
  class QueuesController < BaseController
    def show
      @queue_counts, @queue_error = queue_counts
      @failed_executions = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc).limit(50)
      @scheduled = SolidQueue::Job.joins(:scheduled_execution).order("solid_queue_scheduled_executions.scheduled_at ASC").limit(50)
      @ready = SolidQueue::Job.joins(:ready_execution).order("solid_queue_ready_executions.created_at ASC").limit(50)
    rescue ActiveRecord::StatementInvalid => e
      @queue_error = e.message
      @failed_executions = []
      @scheduled = []
      @ready = []
    end

    def discard_failed
      SolidQueue::FailedExecution.discard_all_in_batches
      redirect_to admin_queue_path, notice: "Failed jobs discarded."
    rescue ActiveRecord::StatementInvalid => e
      redirect_to admin_queue_path, alert: "Unable to discard failed jobs: #{e.message}"
    end

    def retry_failed
      failed_jobs = SolidQueue::Job.joins(:failed_execution).limit(500)
      if failed_jobs.any?
        SolidQueue::FailedExecution.retry_all(failed_jobs)
        notice = "Retried #{failed_jobs.size} failed job(s)."
      else
        notice = "No failed jobs to retry."
      end
      redirect_to admin_queue_path, notice: notice
    rescue ActiveRecord::StatementInvalid => e
      redirect_to admin_queue_path, alert: "Unable to retry failed jobs: #{e.message}"
    end

    def failed
      @failed_execution = SolidQueue::FailedExecution.includes(:job).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_queue_path, alert: "Failed job not found."
    end
  end
end
