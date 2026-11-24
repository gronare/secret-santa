class ApplicationMailer < ActionMailer::Base
  default from: "noreply@gronare.com"
  layout "mailer"

  self.delivery_job = RateLimitedMailDeliveryJob
end
