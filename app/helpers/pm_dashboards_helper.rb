module PmDashboardsHelper

  def pm_dashboard_tabs
    tabs = [{:label => 'Dashboard', :name => 'dashboard', :partial => 'dashboard'},
            {:label => 'Info', :name => 'info', :partial => 'project_info'},
            {:label => 'Assumptions', :name => 'assumptions', :partial => 'assumptions'},
            {:label => 'Project Issues', :name => 'issues', :partial => 'issues'},
            {:label => 'Risks', :name => 'risks', :partial => 'risk'},
            {:label => 'Change Control', :name => 'change_control', :partial => 'change_control'},
            {:label => 'Resource Cost Forecast', :name => 'resource_costs', :partial => 'resource_costs'},
            {:label => 'Project Cost Monitoring', :name => 'cost_monitoring', :partial => 'cost_monitoring'},
            {:label => 'Milestone Plans', :name => 'milestone_plans', :partial => 'milestone_plans'},
            {:label => 'Project Contracts', :name => 'project_contracts', :partial => 'project_contracts'},
            {:label => 'Weekly Highlights', :name => 'highlights', :partial => 'highlights'}
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
  
  def multiple_calendar_for(field_id)
    include_calendar_headers_tags
    image_tag("calendar.png", {:id => "#{field_id}_trigger", :class => "calendar-trigger"}) +
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y-%m-%d', button : '#{field_id}_trigger' , cache: true});")
  end

  def release_milestone_details(milestone, project)
  	@milestone = Milestone.find(milestone)
	  	table = []

	  	table << "<tr>"
	  	table << "<td>#{@milestone.name}</td>"
	  	table << "<td>#{@milestone.original_target_date}</td>"
	  	table << "<td>#{@milestone.latest_re_plan_date}</td>"
	  	table << "<td>#{@milestone.remarks}</td>"
	  	table << "<td>#{@milestone.status}</td>"
	  	table << "<td align='center'>
	  							#{link_to l(:button_edit), {:controller => 'milestone_plans', :action => 'update', :milestone_id => milestone, :project_id => project}, :class => 'icon icon-edit' } 
	  							|| 
	  							#{link_to l(:button_delete), {:controller => 'milestone_plans', :action => 'destroy', :milestone_id => milestone, :project_id => project}, :confirm => l(:text_are_you_sure), :method => :post, :class => 'icon icon-del' }
	  						</td>"
	  	table << "</tr>"
	  	table
  end  
end
