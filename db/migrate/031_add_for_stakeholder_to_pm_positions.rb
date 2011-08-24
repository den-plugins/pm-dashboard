class AddForStakeholderToPmPositions < ActiveRecord::Migration

  def self.up
    add_column :pm_positions, :for_stakeholder, :boolean, :default => '0'
  end

  def self.down
    remove_column :pm_positions, :for_stakeholder
  end
end
