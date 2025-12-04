class LoginToken < ApplicationRecord
  belongs_to :participant

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :active, -> { where("expires_at > ? AND used_at IS NULL", Time.current) }

  def active?
    expires_at > Time.current && used_at.nil?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= 24.hours.from_now
  end
end
