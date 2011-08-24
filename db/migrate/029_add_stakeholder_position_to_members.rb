class AddStakeholderPositionToMembers < ActiveRecord::Migration

  def self.up
    add_column :members, :stakeholder_position, :string
  end

  def self.down
    remove_column :members, :stakeholder_position
  end
end
