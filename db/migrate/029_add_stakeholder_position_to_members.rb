class AddStakeholderPositionToMembers < ActiveRecord::Migration

  def self.up
    add_column :members, :position, :string
  end

  def self.down
    remove_column :members, :position
  end
end
