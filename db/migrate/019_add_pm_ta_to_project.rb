class AddPmTaToProject < ActiveRecord::Migration

  def self.up
    add_column :projects, :proj_manager, :integer
    add_column :projects, :tech_architect, :integer
  end

  def self.down
    remove_column :projects, :proj_manager
    remove_column :projects, :tech_architect
  end
end
