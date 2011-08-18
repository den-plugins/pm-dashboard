class AddBillableToMember < ActiveRecord::Migration

  def self.up
    add_column :members, :billable, :boolean, :default => FALSE
  end

  def self.down
    remove_column :members, :billable
  end
end
