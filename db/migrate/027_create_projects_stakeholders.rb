class CreateProjectsStakeholders < ActiveRecord::Migration
  def self.up
    create_table :projects_stakeholders, :id => false do |t|
      t.column :stakeholder_id, :integer, :null => false
      t.column :project_id, :integer, :null => false
    end
    add_index :projects_stakeholders, [:stakeholder_id, :project_id], :unique => true, :name => :projects_stakeholders_ids
  end
  
  def self.down
    drop_table :projects_stakeholders
  end
end
