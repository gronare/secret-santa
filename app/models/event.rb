class Event < ApplicationRecord
  has_many :participants, dependent: :destroy

  validates :name, presence: true
  validates :organizer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :organizer_name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= SecureRandom.urlsafe_base64(8)
  end
end
