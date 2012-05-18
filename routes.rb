map.connect 'projects/:project_id/project_management/dashboard/:action', :controller => 'pm_dashboards'
map.connect 'projects/:project_id/project_management/info/:action', :controller => 'project_info'
map.connect 'projects/:project_id/project_management/assumptions/:action', :controller => 'assumptions'
map.connect 'projects/:project_id/project_management/project_issues/:action', :controller => 'pm_dashboard_issues'
map.connect 'projects/:project_id/project_management/risks/:action', :controller => 'risks'
map.connect 'projects/:project_id/project_management/forecasts/:action', :controller => 'resource_costs'
map.connect 'projects/:project_id/project_management/bottomline/:action', :controller => 'cost_monitoring'
map.connect 'projects/:project_id/project_management/billability/:action', :controller => 'project_billability'
map.connect 'projects/:project_id/project_management/milestones/:action', :controller => 'milestone_plans'
map.connect 'projects/:project_id/milestones/:action', :controller => 'menu_milestone_plans'
map.connect 'projects/:project_id/project_management/contracts/:action', :controller => 'project_contracts'
map.connect 'projects/:project_id/project_management/highlights/:action', :controller => 'highlights'
map.connect 'projects/:project_id/project_management/highlights/:action/:id', :controller => 'highlights'
map.connect 'projects/:project_id/project_management/utilization/:action', :controller => 'resource_utilization'
map.connect 'projects/:project_id/project_management/timelog/:action', :controller => 'time_logging'
map.connect 'projects/:project_id/project_management/efficiency/:action', :controller => 'efficiency'
map.connect 'projects/:project_id/project_management/efficiency/load_chart.json', :controller => 'efficiency', :action => 'load_chart'
