class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :project_info
  helper :custom_fields
  
  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues = @project.pm_dashboard_issues.all
    @risks = @project.risks.find(:all, :order => 'ref_number DESC')
    @members = @project.members.all(:order => "role_id")
    @project_scope = CustomField.find_by_name("Project Scope")
    if !@project_scope.nil?
      @project_scope_value = @project.custom_values.find(:all, :conditions => "custom_field_id = #{@project_scope.id}")
    end
    @stakeholders = []
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
