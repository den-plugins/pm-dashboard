class CreateAssumptions < ActiveRecord::Migration
  
  def self.up
    create_table :assumptions do |t|
      t.column :project_id, :integer, :null => false
      t.column :ref_number, :string, :null => false
      t.column :description, :text, :null => false
      t.column :validation, :text
      t.column :owner, :integer
      t.column :date_due, :date
      t.column :date_closed, :date
      t.column :days_overdue, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :assumptions
  end
end
