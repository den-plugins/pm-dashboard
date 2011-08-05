class PmDashboardsController < ApplicationController
  helper :assumptions
  
  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues = @project.pm_dashboard_issues.all
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
