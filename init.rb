require 'redmine'
require 's3_attachment/s3_send_file'
require 'dispatcher'

require 'pm_member_patch'
require 'pm_project_patch'

Dispatcher.to_prepare do
  Member.send(:include, Pm::MemberPatch)
  Project.send(:include, Pm::ProjectPatch)
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
                      {   :pm_dashboards => [:index, :update_resource_list, :edit_project],
                            :assumptions => [:add, :update, :destroy],
                            :highlights   => [:save, :post, :unpost],
                            :milestone_plans => [:add, :update, :destroy],
                            :pm_dashboard_issues    => [:add, :edit, :delete],
                            :project_info    => [:update, :pm_member_edit, :pm_member_update, :pm_member_add, :pm_member_remove,
                                                               :update_role_pos, :add_pm_position, :add_pm_role],
                            :resource_allocations => [:index, :add, :edit, :destroy],
                            :risks => [:add, :update, :destroy],
                            :stakeholders => [:new, :create, :edit, :update, :remove],
                            :weeks => [:new, :edit]
                        }, :public => false
  end
  
  menu  :project_menu,
        :pm_dashboards,
        { :controller => 'pm_dashboards', :action => 'index' },
        :caption=> 'PM Dashboard',
        :param => :project_id
end

require File.dirname(__FILE__) + '/app/models/mailer_extn.rb'
require File.dirname(__FILE__) + '/app/models/user_extn.rb'
