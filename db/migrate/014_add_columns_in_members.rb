class AddColumnsInMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :stakeholder, :boolean, :default => FALSE
    add_column :members, :proj_team, :boolean, :default => FALSE
    add_column :members, :pm_role_id, :integer
    add_column :members, :pm_pos_id, :integer
  end

  def self.down
    remove_column :members, :stakeholder
    remove_column :members, :proj_team
    remove_column :members, :pm_role_id
    remove_column :members, :pm_pos_id
  end
end
