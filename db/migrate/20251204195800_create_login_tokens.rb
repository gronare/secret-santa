class CreateLoginTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :login_tokens do |t|
      t.references :participant, null: false, foreign_key: true
      t.string :token
      t.datetime :expires_at
      t.datetime :used_at

      t.timestamps
    end
    add_index :login_tokens, :token, unique: true
  end
end
