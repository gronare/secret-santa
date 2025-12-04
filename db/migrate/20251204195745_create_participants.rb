class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.integer :assigned_to_id
      t.boolean :is_organizer, default: false

      t.timestamps
    end
    add_index :participants, [ :event_id, :email ], unique: true
    add_index :participants, :assigned_to_id
  end
end
