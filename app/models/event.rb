class Event < ApplicationRecord
  has_many :participants, dependent: :destroy
  normalizes :organizer_email, with: ->(email) { email.strip.downcase }

  enum :status, { draft: "draft", active: "active", completed: "completed" }, default: :draft

  validates :name, presence: true
  validates :organizer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :organizer_name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  validates :theme, inclusion: { in: %w[christmas hanukkah winter generic] }, allow_nil: true

  before_validation :generate_slug, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :upcoming, -> { where("event_date >= ?", Date.current).order(:event_date) }

  def to_param
    slug
  end

  def organizer
    participants.find_by(is_organizer: true)
  end

  def participating_count
    # Count all participants except non-participating organizer
    if organizer_participates
      participants.count
    else
      participants.where(is_organizer: false).count
    end
  end

  def ready_to_launch?
    return false if active? || completed?
    participating_count >= 3
  end

  def assignments_drawn?
    participants.where.not(assigned_to_id: nil).exists?
  end

  def launch!
    return false unless ready_to_launch?

    transaction do
      update!(status: :active, launched_at: Time.current)
      true
    end
  end

  private

  def generate_slug
    self.slug ||= SecureRandom.urlsafe_base64(8)
  end
end
