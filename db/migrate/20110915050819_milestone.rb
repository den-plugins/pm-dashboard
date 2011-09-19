class Milestone < ActiveRecord::Migration
  def self.up
  	create_table :milestones do |t|
  		t.column "release_id", :integer
  		t.column "name", :string, :default => "", :null => false
  		t.column "original_target_date", :date
  		t.column "latest_re_plan_date", :date
  		t.column "remarks", :text
  		t.column "status", :string

  		t.timestamps
  	end
  end

  def self.down
  	drop_table :milestones
  end
end
