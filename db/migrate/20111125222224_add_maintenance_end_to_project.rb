class AddMaintenanceEndToProject < ActiveRecord::Migration

  def self.up
    add_column :projects, :maintenance_end, :date
  end

  def self.down
    remove_column :projects, :maintenance_end
  end
end
