module PmDashboardsHelper

  def pm_dashboard_tabs
    tabs = [{:label => 'Dashboard', :name => 'dashboard', :partial => 'dashboard'},
            {:label => 'Info', :name => 'info', :partial => 'project_info'},
            {:label => 'Assumptions', :name => 'assumptions', :partial => 'assumptions'},
            {:label => 'Project Issues', :name => 'issues', :partial => 'issues'},
            {:label => 'Risks', :name => 'risks', :partial => 'risk'},
            {:label => 'Change Control', :name => 'change_control', :partial => 'change_control'},
            {:label => 'Resource Cost Forecast', :name => 'resource_costs', :partial => 'resource_costs'},
            {:label => 'Project Billability', :name => 'billability', :partial => 'project_billability'},
            {:label => 'Milestone Plans', :name => 'milestone_plans', :partial => 'milestone_plans'},
            {:label => 'Project Contracts', :name => 'project_contracts', :partial => 'project_contracts'},
            {:label => 'Weekly Highlights', :name => 'highlights', :partial => 'highlights'},
            {:label => 'Resource Utilization', :name => 'resource_utilization', :partial => 'resource_utilization'},
            {:label => 'Time Logging', :name => 'time_logging', :partial => 'time_logging'}
           ]
    tabs
  end
  
  def render_pm_dashboard_tabs
    if @client
      render_menu(:clients_project_management, @project)
    else
      render_menu :project_management, @project
    end
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

  def display_by_billing_model
    if @project.billing_model
      if @project.billing_model.scan(/^(Fixed)/).flatten.present?
        "fixed"
      elsif @project.billing_model.scan(/^(T and M)/i).flatten.present?
        "billability"
      end
    end
  end

  def json_billability_per_week(start_date, end_date, resources)
    billability_per_week = []
    weeks = get_weeks_range(start_date, end_date)
    weeks.each_with_index do |week, wnum|
      forecast = compute_forecasted_hours week, resources
      actual = compute_actual_hours week, resources
      bill = compute_percent_to_date forecast, actual
      billability_per_week << [week.last, bill.to_f] if week.last < (Date.today.monday + 4.days)
    end unless  weeks.nil? or weeks.empty?
    billability_per_week.to_json
  end

  def compute_percentage_utilization(members, from=nil, to=nil)
    return 0 unless members.count > 0
    from, to = (mon=(Date.today-1.week).monday), mon+4.days unless from && to
    range = from .. to
    total = members.count
    completed = members.select {|m| m.with_complete_logs_for_all?(range) }.count
    (completed.to_f/total.to_f) * 100
  end
  
  def is_aposted?(highlight)
    highlight && highlight.posted?
  end
end
