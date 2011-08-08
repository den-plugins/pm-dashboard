class UpdateDatatypeForIssuesImpact < ActiveRecord::Migration

  def self.up
    change_column(:pm_dashboard_issues, :impact, :string)
  end

  def self.down
    change_column(:pm_dashboard_issues, :impact, :integer)
  end

end