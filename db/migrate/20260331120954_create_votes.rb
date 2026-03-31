class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :proposal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false
      t.timestamps
    end
    add_index :votes, [ :user_id, :proposal_id ], unique: true
  end
end
