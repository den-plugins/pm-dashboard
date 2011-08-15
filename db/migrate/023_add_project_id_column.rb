class AddProjectIdColumn < ActiveRecord::Migration

  def self.up
    add_column :assumptions, :pid, :integer
    add_column :pm_dashboard_issues, :pid, :integer
    add_column :risks, :pid, :integer
  end

  def self.down
    remove_column :assumptions, :pid
    remove_column :pm_dashboard_issues, :pid
    remove_column :risks, :pid, :integer
  end
end
