class CreateRisks < ActiveRecord::Migration
  
  def self.up
    create_table :risks do |t|
      t.column :ref_number, :string
      t.column :env, :string
      t.column :risk_type, :string
      t.column :risk_description, :text
      t.column :potential_effect, :text
      t.column :probability, :integer
      t.column :impact, :integer
      t.column :initial_risk_rating, :integer
      t.column :owner, :integer
      t.column :mitigating_action, :text
      t.column :probability_final, :integer
      t.column :impact_final, :integer
      t.column :final_risk_rating, :integer
      t.column :target_resolution_date, :date
      t.column :days_overdue, :integer
      t.column :status, :string
      t.column :project_id, :integer
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :risks
  end
  
end
