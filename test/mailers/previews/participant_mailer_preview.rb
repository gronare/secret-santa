# Preview all emails at http://localhost:3000/rails/mailers/participant_mailer
# Preview all emails at http://localhost:3000/rails/mailers/participant_mailer
class ParticipantMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/participant_mailer/invitation
  def invitation
    with_preview_data do
      ParticipantMailer.invitation(sample_participant)
    end
  end

  # Preview this email at http://localhost:3000/rails/mailers/participant_mailer/assignment
  def assignment
    with_preview_data do
      gifter = sample_participant
      giftee = sample_giftee
      gifter.assigned_to = giftee
      gifter.assigned_to_id = giftee.id
      gifter.define_singleton_method(:assigned_participant) { giftee }

      ParticipantMailer.assignment(gifter)
    end
  end

  # Preview this email at http://localhost:3000/rails/mailers/participant_mailer/wishlist_ready
  def wishlist_ready
    with_preview_data do
      gifter = sample_participant
      giftee = sample_giftee
      gifter.assigned_to = giftee
      gifter.assigned_to_id = giftee.id
      gifter.define_singleton_method(:assigned_participant) { giftee }
      ensure_wishlist_item!(giftee)

      ParticipantMailer.wishlist_ready(gifter, giftee)
    end
  end

  # Preview this email at http://localhost:3000/rails/mailers/participant_mailer/wishlist_reminder
  def wishlist_reminder
    with_preview_data do
      participant = reminder_participant
      participant.wishlist_items.destroy_all

      ParticipantMailer.wishlist_reminder(participant)
    end
  end

  private

  # Ensure preview data does not persist in the development database
  def with_preview_data
    mail = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      mail = yield
      raise ActiveRecord::Rollback
    end
    mail
  end

  def sample_event
    Event.find_or_create_by!(slug: "preview-event") do |event|
      event.name = "Secret Santa Preview"
      event.organizer_name = "Preview Organizer"
      event.organizer_email = "organizer+preview@example.com"
      event.event_date = 1.month.from_now.to_date
      event.status = :active
    end
  end

  def sample_participant
    ensure_participant("gifter", "Gifter Gale")
  end

  def sample_giftee
    ensure_participant("giftee", "Giftee Grace")
  end

  def reminder_participant
    ensure_participant("reminder", "Reminder Riley")
  end

  def ensure_participant(key, name)
    email = "#{key}+preview@example.com"
    user = User.find_or_create_by!(email: email)

    Participant.find_or_create_by!(event: sample_event, email: email) do |participant|
      participant.user = user
      participant.name = name
    end
  end

  def ensure_wishlist_item!(participant)
    participant.wishlist_items.first_or_create!(
      description: "Warm wool socks",
      url: "https://example.com/wool-socks",
      price: "~25 USD"
    )
  end
end
