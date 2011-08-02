class PmDashboardsController < ApplicationController

  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.all
    @issues = @project.pm_dashboard_issues.all
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
