class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :risks
  helper :project_info
  
  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues = @project.pm_dashboard_issues.all
    @risks = @project.risks.find(:all, :order => 'ref_number DESC')
    @members = @project.members.all(:order => "role_id")
    @stakeholders = []
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
