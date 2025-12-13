class ApplicationMailer < ActionMailer::Base
  default from: "noreply@secretsanta.gronare.com"
  layout "mailer"

  self.delivery_job = RateLimitedMailDeliveryJob
end
