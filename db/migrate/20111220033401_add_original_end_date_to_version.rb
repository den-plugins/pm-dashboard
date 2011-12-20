class AddOriginalEndDateToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :original_end_date, :date
    rename_column :versions, :original_date, :original_start_date
  end

  def self.down
    remove_column :versions, :original_end_date
    remove_column :versions, :original_start_date
  end
end
