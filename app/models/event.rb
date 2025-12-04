class Event < ApplicationRecord
  # Associations with strict loading to avoid N+1 queries
  has_many :participants, dependent: :destroy, strict_loading: true

  # Modern Rails: Normalize email to lowercase and strip whitespace
  normalizes :organizer_email, with: -> email { email.strip.downcase }

  # Validations
  validates :name, presence: true
  validates :organizer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :organizer_name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Modern Rails: generates_token_for for magic link tokens
  generates_token_for :organizer_access, expires_in: 24.hours

  before_validation :generate_slug, on: :create

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :upcoming, -> { where("event_date >= ?", Date.current).order(:event_date) }

  def to_param
    slug
  end

  def organizer
    participants.find_by(is_organizer: true)
  end

  def ready_to_draw?
    participants.count >= 3
  end

  def assignments_drawn?
    participants.where.not(assigned_to_id: nil).exists?
  end

  private

  def generate_slug
    self.slug ||= SecureRandom.urlsafe_base64(8)
  end
end
