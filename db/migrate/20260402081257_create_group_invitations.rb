class CreateGroupInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :group_invitations do |t|
      t.string :token, null: false
      t.references :group, null: false, foreign_key: true
      t.bigint :created_by, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :group_invitations, :token, unique: true
    add_foreign_key :group_invitations, :users, column: :created_by
  end
end
