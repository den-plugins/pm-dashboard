class PmDashboardIssuesController < ApplicationController

  helper :assumptions

  before_filter :require_login
  before_filter :get_project, :only => [:add, :edit, :delete]
  before_filter :get_issue, :only => [:edit, :delete]

  def index
  end

  def add
    if request.get?
      @issue = PmDashboardIssue.new
      render :template => "pm_dashboards/pm_dashboard_issues/add"
    else
      @issue = @project.pm_dashboard_issues.create(params[:issue])
      if @issue.save
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :issues
      else
        render :template => "pm_dashboards/pm_dashboard_issues/add"
      end
    end
  end

  def edit
    if request.get?
      render :template => "pm_dashboards/pm_dashboard_issues/edit"
    else
      if @issue.update_attributes(params[:issue])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :issues
      else
        render :template => "pm_dashboards/pm_dashboard_issues/edit"
      end
    end
  end

  def delete
    if @issue.destroy
      redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :issues
    end
  end

  def get_project
    @project = Project.find(params[:project_id])
  end

  def get_issue
    @issue = PmDashboardIssue.find(params[:id])
  end
end
