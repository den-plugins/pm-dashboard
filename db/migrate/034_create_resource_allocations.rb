class CreateResourceAllocations < ActiveRecord::Migration
  
  def self.up
    create_table :resource_allocations do |t|
      t.column :from, :date
      t.column :to, :date
      t.column :resource_allocation, :integer
      t.column :member_id, :integer
    end
  end

  def self.down
    drop_table :resource_allocations
  end
end
