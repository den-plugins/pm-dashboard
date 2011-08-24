class AddForStakeholderToPmRoles < ActiveRecord::Migration

  def self.up
    add_column :pm_roles, :for_stakeholder, :boolean, :default => '0'
  end

  def self.down
    remove_column :pm_roles, :for_stakeholder
  end
end
