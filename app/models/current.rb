# Current attributes for request-scoped data
# This uses Rails' Current Attributes pattern to store per-request context
class Current < ActiveSupport::CurrentAttributes
  attribute :participant, :event, :request_id, :user_agent

  def participant=(participant)
    super
    self.event = participant&.event
  end

  resets { Time.zone = nil }
end
