class AddNewFieldsToProject < ActiveRecord::Migration

  def self.up
    add_column :projects, :client, :text
    add_column :projects, :planned_start_date, :date
    add_column :projects, :planned_end_date, :date
  end

  def self.down
    remove_column :projects, :scope
    remove_column :projects, :planned_start_date
    remove_column :projects, :planned_end_date
  end
end
