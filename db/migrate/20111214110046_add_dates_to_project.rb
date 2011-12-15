class AddDatesToProject < ActiveRecord::Migration
  
  def self.up
    add_column :projects, :actual_start_date, :date
    add_column :projects, :actual_end_date, :date
  end

  def self.down
    remove_column :projects, :actual_start_date
    remove_column :projects, :actual_end_date
  end
end
