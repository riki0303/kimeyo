class RemoveUsedAtFromGroupInvitations < ActiveRecord::Migration[8.1]
  def change
    remove_column :group_invitations, :used_at, :datetime
  end
end
