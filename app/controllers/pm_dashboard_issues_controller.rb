class PmDashboardIssuesController < ApplicationController

  menu_item :project_issues
  
  helper :pm_dashboards

  before_filter :require_login
  before_filter :get_project, :only => [:index, :add, :edit, :delete]
  before_filter :get_issue, :only => [:edit, :delete]

  def index
    @issue = PmDashboardIssue.find(params[:id]) if params[:id]
    @project ||= @issue.project
    @issues = params[:id] ? [@issue] : @project.pm_dashboard_issues.find(:all, :order => 'ref_number DESC')
  end

  def add
    if request.get?
      @issue = PmDashboardIssue.new
      render :template => "pm_dashboard_issues/add"
    else
      @issue = @project.pm_dashboard_issues.create(params[:issue])
      if @issue.save
        redirect_to_project_issues
      else
        render :template => "pm_dashboard_issues/add"
      end
    end
  end

  def edit
    if request.get?
      render :template => "pm_dashboard_issues/edit"
    else
      if @issue.update_attributes(params[:issue])
        redirect_to_project_issues
      else
        render :template => "pm_dashboard_issues/edit"
      end
    end
  end

  def delete
    if @issue.destroy
      redirect_to_project_issues
    end
  end

  private
  def get_project
    @project = Project.find(params[:project_id])
  end

  def get_issue
    @issue = PmDashboardIssue.find(params[:id])
  end
  
  def redirect_to_project_issues
    redirect_to :controller => 'pm_dashboard_issues', :action => 'index', :project_id => @project
  end
end
