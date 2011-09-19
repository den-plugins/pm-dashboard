class AddKeyIssueToPmDashboardIssue < ActiveRecord::Migration
  def self.up
    add_column :pm_dashboard_issues, :key_issue, :boolean
  end

  def self.down
    remove_column :pm_dashboard_issues, :key_issue
  end
end
