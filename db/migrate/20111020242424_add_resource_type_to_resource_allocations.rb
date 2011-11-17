class AddResourceTypeToResourceAllocations < ActiveRecord::Migration
  def self.up
    add_column :resource_allocations, :resource_type, :integer
  end

  def self.down
    remove_column :resource_allocations, :resource_type
  end
end
