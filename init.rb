require 'redmine'
require 's3_attachment/s3_send_file'
require 'dispatcher'

require 'pm_member_patch'
require 'pm_project_patch'
require 'attachment_patch'

Dispatcher.to_prepare do
  Member.send(:include, Pm::MemberPatch)
  Project.send(:include, Pm::ProjectPatch)
  Attachment.send(:include, Pm::AttachmentPatch)
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
    permission :list_dashboards,
                      {   :pm_dashboards => [:index],
                            :assumptions => [:index, :add, :update, :destroy],
                            :highlights   => [:save, :post, :unpost],
                            :milestone_plans => [:add, :update, :destroy],
                            :pm_dashboard_issues    => [:index, :add, :edit, :delete],
                            :project_info    => [:index, :update, :pm_member_edit, :pm_member_update, :pm_member_add, :pm_member_remove,
                                                               :update_role_pos, :add_pm_position, :add_pm_role],
                            :resource_allocations => [:index, :add, :edit, :destroy],
                            :risks => [:add, :update, :destroy],
                            :project_contracts => [:add, :update, :destroy],
                            :stakeholders => [:new, :create, :edit, :update, :remove],
                            :weeks => [:new, :edit]
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
#    menu.push :risks, {:controller => 'pm_dashboards', :action =>'risks' }
#    menu.push :forecasts, {:controller => 'pm_dashboards', :action =>'forecasts' }, :caption => 'Resource Cost Forecast'
#    menu.push :billability, {:controller => 'pm_dashboards', :action =>'billability' }, :caption => 'Project Billability'
#    menu.push :milestones, {:controller => 'pm_dashboards', :action =>'milestones' }, :caption => 'Milestone Plans'
#    menu.push :contracts, {:controller => 'pm_dashboards', :action =>'contracts' }, :caption => 'Project Contracts'
#    menu.push :highlights, {:controller => 'pm_dashboards', :action =>'highlights' }, :caption => 'Weekly Highlights'
  end
end

require File.dirname(__FILE__) + '/app/models/mailer_extn.rb'
require File.dirname(__FILE__) + '/app/models/user_extn.rb'
