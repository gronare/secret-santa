# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/event_mailer/organizer_welcome
  def organizer_welcome
    EventMailer.organizer_welcome
  end
end
