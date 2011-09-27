class AddColumnRemarksToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :remarks, :text
  end

  def self.down
    remove_column :versions, :remarks
  end
end
