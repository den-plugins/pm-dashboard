class PmDashboardsController < ApplicationController

  menu_item :dashboard, :only => :index
  helper :project_billability
  
  before_filter :get_project, :only => [:index]
  before_filter :authorize, :only => [:index]
  
  def index
    @highlights = @project.weekly_highlights
    @key_risks ||= @project.risks.key
    @key_issues ||= @project.pm_dashboard_issues.key

    @current_sprint = @project.current_version
    @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    
    @project_resources  = @project.members.select(&:billable?)
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
