class AddUserIdToParticipants < ActiveRecord::Migration[8.1]
  def change
    # Add user_id column without constraint first
    add_reference :participants, :user, foreign_key: true

    # Migrate existing data
    reversible do |dir|
      dir.up do
        # Create User records for each unique email and associate participants
        execute <<-SQL
          INSERT INTO users (email, created_at, updated_at)
          SELECT DISTINCT email, NOW(), NOW()
          FROM participants
          ON CONFLICT (email) DO NOTHING;
        SQL

        execute <<-SQL
          UPDATE participants
          SET user_id = users.id
          FROM users
          WHERE participants.email = users.email;
        SQL
      end
    end

    # Add null constraint after data migration
    change_column_null :participants, :user_id, false
  end
end
