class AddImpactInIssues < ActiveRecord::Migration

  def self.up
    add_column :pm_dashboard_issues, :impact, :integer
  end

  def self.down
    remove_column :pm_dashboard_issues, :impact
  end

end