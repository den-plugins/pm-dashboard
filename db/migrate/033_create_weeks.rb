class CreateWeeks < ActiveRecord::Migration
  
  def self.up
    create_table :weeks do |t|
      t.column :from, :date
      t.column :to, :date
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :weeks
  end
end
