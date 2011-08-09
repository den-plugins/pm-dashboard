class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :risks
  
  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues = @project.pm_dashboard_issues.all
    @risks = @project.risks.find(:all, :order => 'ref_number DESC')
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
