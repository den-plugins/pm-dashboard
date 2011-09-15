class RenameColumnsInResourceAllocations < ActiveRecord::Migration
  def self.up
    rename_column :resource_allocations, :from, :start_date
    rename_column :resource_allocations, :to, :end_date
  end
  
  def self.down
    raise IrreversibleMigration
  end
end
