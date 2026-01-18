class CreateProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :proposals do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
