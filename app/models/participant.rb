class Participant < ApplicationRecord
  belongs_to :event
  belongs_to :assigned_to, class_name: "Participant", optional: true
  has_many :login_tokens, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :event_id }

  def assigned_participant
    Participant.find_by(id: assigned_to_id)
  end
end
