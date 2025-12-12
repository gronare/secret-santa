class Participant < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :event, touch: true
  belongs_to :assigned_to, class_name: "Participant", optional: true
  has_many :login_tokens, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy

  # Modern Rails: Normalize email to lowercase and strip whitespace
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :event_id }

  # Scopes
  scope :organizers, -> { where(is_organizer: true) }
  scope :non_organizers, -> { where(is_organizer: false) }
  scope :with_assignments, -> { where.not(assigned_to_id: nil) }
  scope :without_assignments, -> { where(assigned_to_id: nil) }

  # Delegations
  delegate :name, to: :event, prefix: true, allow_nil: true

  def assigned_participant
    Participant.find_by(id: assigned_to_id)
  end

  def has_assignment?
    assigned_to_id.present?
  end

  def organizer?
    is_organizer?
  end

  def gifter
    Participant.find_by(assigned_to_id: id)
  end
end
