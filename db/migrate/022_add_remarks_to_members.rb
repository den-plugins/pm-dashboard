class AddRemarksToMembers < ActiveRecord::Migration

  def self.up
    add_column :members, :remarks, :text
  end

  def self.down
    remove_column :members, :remarks
  end
end
