module Admin
  class BaseController < ApplicationController
    before_action :require_admin
    layout "admin"

    private

    def require_admin
      password = ENV["ADMIN_DASHBOARD_PASSWORD"]
      username = ENV.fetch("ADMIN_DASHBOARD_USER", "admin")

      if password.blank?
        render plain: "Admin dashboard disabled: missing ADMIN_DASHBOARD_PASSWORD", status: :unauthorized
        return
      end

      authenticate_or_request_with_http_basic("Admin") do |provided_user, provided_pass|
        ActiveSupport::SecurityUtils.secure_compare(provided_user, username) &&
          ActiveSupport::SecurityUtils.secure_compare(provided_pass, password)
      end
    end

    def queue_counts
      counts = {
        jobs: SolidQueue::Job.count,
        scheduled: SolidQueue::ScheduledExecution.count,
        ready: SolidQueue::ReadyExecution.count,
        claimed: SolidQueue::ClaimedExecution.count,
        failed: SolidQueue::FailedExecution.count
      }
      [ counts, nil ]
    rescue ActiveRecord::StatementInvalid => e
      [ {}, e.message ]
    end
  end
end
