class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name
      t.date :event_date
      t.string :location
      t.string :budget
      t.text :description
      t.string :theme_primary_color
      t.string :theme_secondary_color
      t.text :custom_message
      t.string :organizer_email
      t.string :organizer_name
      t.string :slug

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end
