map.with_options :controller => 'pm_dashboards' do |group_routes|
  group_routes.with_options :conditions => {:method => :get} do |group_views|
    group_views.connect 'pm_dashboards/:project_id/:tab', :action => 'index'
  end
  group_routes.with_options :conditions => {:method => :post} do |group_views|
    group_views.connect 'pm_dashboards/:project_id/:tab', :action => 'index'
  end
end

map.connect 'pm_dashboards/:project_id/resource_costs/:user_id', :controller => 'resource_costs', :action => 'allocation'
