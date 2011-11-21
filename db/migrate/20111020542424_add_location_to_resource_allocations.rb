class AddLocationToResourceAllocations < ActiveRecord::Migration
  def self.up
    add_column :resource_allocations, :location, :integer
  end

  def self.down
    remove_column :resource_allocations, :location
  end
end
