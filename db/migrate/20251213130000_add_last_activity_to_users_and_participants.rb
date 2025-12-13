class AddLastActivityToUsersAndParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :last_activity_at, :datetime
    add_column :users, :last_activity_at, :datetime
  end
end
