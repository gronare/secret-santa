# frozen_string_literal: true

class RateLimitedMailDeliveryJob < ActionMailer::MailDeliveryJob
  class Throttled < StandardError; end

  retry_on Throttled, wait: 0.5.seconds, attempts: 1_000_000

  def perform(mailer, mail_method, delivery_method, args:, kwargs: nil, params: nil)
    raise Throttled unless EmailRateLimiter.allowed?(limit: 2, period: 1.second)
    super
  end
end
