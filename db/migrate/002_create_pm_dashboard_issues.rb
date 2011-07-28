class CreatePmDashboardIssues < ActiveRecord::Migration
  def self.up
    create_table :pm_dashboard_issues do |t|
      t.column :env, :string
      t.column :date_raised, :date
      t.column :raised_by, :integer
      t.column :issue_description, :text
      t.column :action, :text
      t.column :impact, :integer
      t.column :owner, :integer
      t.column :date_due, :date
      t.column :days_overdue, :integer
      t.column :date_close, :date
      t.column :related_risk_assumption, :integer
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :pm_dashboard_issues
  end
end
