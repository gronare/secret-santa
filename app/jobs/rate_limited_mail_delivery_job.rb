class RateLimitedMailDeliveryJob < ActionMailer::MailDeliveryJob
  def perform(mailer, mail_method, delivery_method, args:, kwargs: nil, params: nil)
    EmailRateLimiter.wait!
    super
  end
end
