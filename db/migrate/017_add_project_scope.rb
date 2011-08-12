class AddProjectScope < ActiveRecord::Migration

  def self.up
    add_column :projects, :scope, :text
  end

  def self.down
    remove_column :projects, :scope
  end
end
