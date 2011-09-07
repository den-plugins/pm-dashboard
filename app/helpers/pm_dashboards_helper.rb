module PmDashboardsHelper

  def pm_dashboard_tabs
    tabs = [{:label => 'Dashboard', :name => 'dashboard', :partial => 'dashboard_header'},
            {:label => 'Info', :name => 'info', :partial => 'project_info'},
            {:label => 'Assumptions', :name => 'assumptions', :partial => 'assumptions'},
            {:label => 'Project Issues', :name => 'issues', :partial => 'issues'},
            {:label => 'Risks', :name => 'risks', :partial => 'risk'},
            {:label => 'Change Control', :name => 'change_control', :partial => 'change_control'},
            {:label => 'Resource Cost Forecast', :name => 'resource_cost', :partial => 'resource_cost'}
            ]
    tabs
  end
  
  def collection_for_risk_select(related)
    @project.risks.select { |r| !related.risks.include?(r) }
  end
  
  def collection_for_assumption_select(related)
    @project.assumptions.select { |r| !related.assumptions.include?(r) }
  end
  
  def collection_for_issues_select(related)
    @project.pm_dashboard_issues.select {|r| !related.pm_dashboard_issues.include?(r) }
  end
  
  def remote_labelled_tabular_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    remote_form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => current_language}), &proc)
  end
end
