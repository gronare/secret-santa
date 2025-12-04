class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :participant, null: false, foreign_key: true
      t.text :description
      t.string :url
      t.integer :priority

      t.timestamps
    end
  end
end
