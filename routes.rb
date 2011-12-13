map.connect 'pm_dashboards/:project_id/resource_costs/:action/:user_id', :controller => 'resource_costs', :action => 'allocation'
map.connect 'projects/:controller/:project_id/:action',
    :controller => [:pm_dashboards, :project_info, :assumptions, :highlights, :milestone_plans, :pm_dashboard_issues, :project_contracts, :resource_allocations, :risks, :stakeholders]
