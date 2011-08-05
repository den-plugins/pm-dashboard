class AddListDashboardsPermission < ActiveRecord::Migration
  
  def self.up
    Role.find(3).add_permission!(:list_dashboards) 
  end
  
  def self.down
    Role.find(3).remove_permission!(:list_dashboards)
  end
end
