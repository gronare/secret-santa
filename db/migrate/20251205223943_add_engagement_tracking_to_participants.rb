class AddEngagementTrackingToParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :last_sign_in_at, :datetime
    add_column :participants, :invitation_sent_at, :datetime
  end
end
