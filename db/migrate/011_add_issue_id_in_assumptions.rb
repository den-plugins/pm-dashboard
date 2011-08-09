class AddIssueIdInAssumptions < ActiveRecord::Migration

  def self.up
    add_column :assumptions, :pm_dashboard_issue_id, :integer
  end

  def self.down
    remove_column :assumptions, :pm_dashboard_issue_id
  end
end
