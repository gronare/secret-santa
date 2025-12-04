class WishlistItem < ApplicationRecord
  belongs_to :participant

  validates :description, presence: true

  default_scope { order(priority: :desc, created_at: :desc) }
end
