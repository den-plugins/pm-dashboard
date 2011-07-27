class CreatePmDashboards < ActiveRecord::Migration
  def self.up
    create_table :pm_dashboards do |t|
    end
  end

  def self.down
    drop_table :pm_dashboards
  end
end
