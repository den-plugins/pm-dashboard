class RemoveImpactInIssues < ActiveRecord::Migration

  def self.up
    remove_column :pm_dashboard_issues, :impact
  end

  def self.down
    add_column :pm_dashboard_issues, :impact, :string
  end

end