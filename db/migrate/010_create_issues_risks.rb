class CreateIssuesRisks < ActiveRecord::Migration

  def self.up
    create_table :pm_dashboard_issues_risks, :id => false do |t|
      t.column :pm_dashboard_issue_id, :integer, :null => false
      t.column :risk_id, :integer, :null => false
    end
    add_index :pm_dashboard_issues_risks, [:pm_dashboard_issue_id, :risk_id], :unique => true, :name => :pm_dashboard_issues_risks_ids
  end

  def self.down
    drop_table :pm_dashboard_issues_risks
  end
end
