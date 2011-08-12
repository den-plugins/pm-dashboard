class RenameDateRaised < ActiveRecord::Migration

  def self.up
    rename_column :pm_dashboard_issues, :date_raised, :created_on
    add_column :pm_dashboard_issues, :updated_on, :date
  end

  def self.down
    raise IrreversibleMigration
    remove_column :pm_dashboard_issues, :updated_on
  end

end
