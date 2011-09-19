class AddDateColumnsToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :start_date, :date
    add_column :versions, :original_date, :date
  end

  def self.down
    remove_column :versions, :original_date
    remove_column :versions, :start_date
  end
end
