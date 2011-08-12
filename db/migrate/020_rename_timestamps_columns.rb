class RenameTimestampsColumns < ActiveRecord::Migration

  def self.up
    rename_column :assumptions, :created_at, :created_on
    rename_column :assumptions, :updated_at, :updated_on
    rename_column :risks, :created_at, :created_on
    rename_column :risks, :updated_at, :updated_on
  end
  
  def self.down
    raise IrreversibleMigration
  end
  
end
