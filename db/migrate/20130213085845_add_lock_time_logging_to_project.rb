class AddLockTimeLoggingToProject < ActiveRecord::Migration
  def self.up
  	add_column :projects, :lock_time_logging, :boolean, :default => false, :null => false
  end

  def self.down
  	remove_column :projects, :lock_time_logging
  end
end
