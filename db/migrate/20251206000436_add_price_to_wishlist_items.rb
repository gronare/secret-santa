class AddPriceToWishlistItems < ActiveRecord::Migration[8.1]
  def change
    add_column :wishlist_items, :price, :string
  end
end
