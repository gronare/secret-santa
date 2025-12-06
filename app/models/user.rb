class User < ApplicationRecord
  has_many :participants, dependent: :destroy

  # Normalize email to lowercase and strip whitespace
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true

  # Modern Rails: generates_token_for for magic link authentication
  generates_token_for :magic_link, expires_in: 24.hours do
    # Include email in token to prevent reuse if email changes
    email
  end
end
