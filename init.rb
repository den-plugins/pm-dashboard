require 'redmine'

Redmine::Plugin.register :redmine_pm_dashboards do
  name 'Redmine Pm Dashboards plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  project_module :pm_dashboards do
    permission :list_dashboards, :pm_dashboards => :index
  end
  
  menu  :project_menu, 
        :pm_dashboards, 
        { :controller => 'pm_dashboards', :action => 'index' }, 
        :caption=> 'PM Dashboard', 
        :after => :activity, 
        :param => :project_id
end

require File.dirname(__FILE__) + '/app/models/project_extn.rb'
