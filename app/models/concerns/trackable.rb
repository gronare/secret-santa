# Concern for tracking creation and updates with Current attributes
module Trackable
  extend ActiveSupport::Concern

  included do
    before_create :set_request_id
    after_commit :log_creation, on: :create
  end

  private

  def set_request_id
    self.metadata ||= {}
    self.metadata["request_id"] = Current.request_id if Current.request_id
    self.metadata["user_agent"] = Current.user_agent if Current.user_agent
  end

  def log_creation
    Rails.logger.info "[#{self.class.name}##{id}] Created by request #{metadata&.dig('request_id')}"
  end
end
