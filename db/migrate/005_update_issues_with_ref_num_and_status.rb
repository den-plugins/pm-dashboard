class UpdateIssuesWithRefNumAndStatus < ActiveRecord::Migration

  def self.up
    add_column :pm_dashboard_issues, :ref_number, :string
    add_column :pm_dashboard_issues, :status, :string
  end

  def self.down
    remove_column :pm_dashboard_issues, :ref_number
    remove_column :pm_dashboard_issues, :status
  end
end
