class AddDateColumnsToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :started_date, :date
    add_column :versions, :original_date, :date
    add_column :versions, :version_type, :integer
    add_column :versions, :state, :integer
  end

  def self.down
    remove_column :versions, :original_date
    remove_column :versions, :started_date
    remove_column :versions, :version_type
    remove_column :versions, :state
  end
end
