require 'redmine'
require 's3_attachment/s3_send_file'
require 'dispatcher'

require 'pm_member_patch'
require 'pm_project_patch'
require 'pm_version_patch'
require 'attachment_patch'

Dispatcher.to_prepare do
  Member.send(:include, Pm::MemberPatch)
  Project.send(:include, Pm::ProjectPatch)
  Attachment.send(:include, Pm::AttachmentPatch)
  Version.send(:include, Pm::VersionPatch)
end

config.after_initialize do
  ActiveRecord::Base.observers << :assumption_observer
  ActiveRecord::Base.observers << :pm_dashboard_issue_observer
  ActiveRecord::Base.observers << :risk_observer
end

Redmine::Plugin.register :pm_dashboard do
  name 'Redmine Pm Dashboards plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  
  project_module :pm_dashboards do
    permission  :list_dashboards,
                      {  :assumptions => [:index, :show, :add, :update, :destroy],
                          :cost_monitoring => [:index],
                          :highlights => [:index, :save, :update_highlight, :post, :unpost, :select_by_week, :select_duplicate],
                          :milestone_plans => [:index, :add, :update, :destroy],
                          :pm_dashboard_issues => [:index, :show, :add, :edit, :delete],
                          :pm_dashboards => [:index],
                          :project_billability => [:index],
                          :project_contracts => [:index, :add, :update, :destroy],
                          :project_info => [:index, :add, :update, :destroy, :add_pm_position, :add_pm_role, :pm_member_add, :pm_member_edit],
                          :resource_allocations => [:index, :add, :edit, :bulk_edit, :destroy, :multiple_allocations],
                          :resource_costs => [:index, :edit_project],
                          :resource_utilization => [:index],
                          :risks => [:index, :show, :add, :update, :destroy],
                          :stakeholders => [:new, :create, :edit, :update, :remove],
                          :resource_utilization => [:index],
                          :efficiency => [:index, :update_test_code_coverage],
                          :time_logging => [:index]
                      }, :public => false
  end
  
  menu  :project_menu, :pm_dashboards,
            {:controller => 'pm_dashboards', :action => 'index' },
              :caption=> 'PM Dashboard',
              :param => :project_id

  Redmine::MenuManager.map :project_management do |menu|
    menu.push :dashboard, {:controller => 'pm_dashboards', :action => 'index' }, :param => :project_id
    menu.push :info, {:controller => 'project_info', :action =>'index' }, :param => :project_id
    menu.push :assumptions, {:controller => 'assumptions', :action =>'index' }, :param => :project_id
    menu.push :project_issues, {:controller => 'pm_dashboard_issues', :action => 'index'}, :param => :project_id
    menu.push :risks, {:controller => 'risks', :action =>'index' }, :param => :project_id
    menu.push :forecasts, {:controller => 'resource_costs', :action =>'index' }, :caption => 'Resource Cost Forecast', :param => :project_id
    menu.push :bottomline, {:controller => 'cost_monitoring', :action => 'index'}, :caption => 'Bottomline Cost Monitoring', :param => :project_id
    menu.push :utilization, {:controller => 'resource_utilization', :action =>'index' }, :caption => 'Resource Utilization', :param => :project_id
    menu.push :efficiency, { :controller => 'efficiency', :action => 'index' }, :caption => 'Efficiency', :param => :project_id
    menu.push :time_logging, {:controller => 'time_logging', :action =>'index' }, :caption => 'Time Logging', :param => :project_id
    menu.push :billability, {:controller => 'project_billability', :action =>'index' }, :caption => 'Project Billability', :param => :project_id
    menu.push :milestones, {:controller => 'milestone_plans', :action =>'index' }, :caption => 'Milestone Plans', :param => :project_id
    menu.push :contracts, {:controller => 'project_contracts', :action =>'index' }, :caption => 'Project Contracts', :param => :project_id
    menu.push :highlights, {:controller => 'highlights', :action =>'index' }, :caption => 'Weekly Highlights', :param => :project_id
  end
  
    Redmine::MenuManager.map :clients_project_management do |menu|
    menu.push :dashboard, {:controller => 'pm_dashboards', :action => 'index' }, :param => :project_id
    menu.push :info, {:controller => 'project_info', :action =>'index' }, :param => :project_id
    menu.push :assumptions, {:controller => 'assumptions', :action =>'index' }, :param => :project_id
    menu.push :project_issues, {:controller => 'pm_dashboard_issues', :action => 'index'}, :param => :project_id
    menu.push :risks, {:controller => 'risks', :action =>'index' }, :param => :project_id
    menu.push :milestones, {:controller => 'milestone_plans', :action =>'index' }, :caption => 'Milestone Plans', :param => :project_id
    menu.push :contracts, {:controller => 'project_contracts', :action =>'index' }, :caption => 'Project Contracts', :param => :project_id
    menu.push :highlights, {:controller => 'highlights', :action =>'index' }, :caption => 'Weekly Highlights', :param => :project_id
  end
end

require File.dirname(__FILE__) + '/app/models/mailer_extn.rb'
require File.dirname(__FILE__) + '/app/models/user_extn.rb'
