class CreateAssumptionsRisks < ActiveRecord::Migration
  
  def self.up
    create_table :assumptions_risks, :id => false do |t|
      t.column :assumption_id, :integer, :null => false
      t.column :risk_id, :integer, :null => false
    end
    add_index :assumptions_risks, [:assumption_id, :risk_id], :unique => true, :name => :assumptions_risks_ids
  end
  
  def self.down
    drop_table :assumptions_risks
  end
end
