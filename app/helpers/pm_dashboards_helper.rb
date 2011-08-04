module PmDashboardsHelper

  def pm_dashboard_tabs
    tabs = [{:label => 'Dashboard', :name => 'dashboard', :partial => 'dashboard_header'},
            {:label => 'Info', :name => 'info', :partial => 'project_info'},
            {:label => 'Assumptions', :name => 'assumptions', :partial => 'assumptions'},
            {:label => 'Issues', :name => 'issues', :partial => 'issues'},
            {:label => 'Risks', :name => 'risks', :partial => 'risk'},
            {:label => 'Change Control', :name => 'change_control', :partial => 'change_control'},
            ]
    tabs
  end

end
