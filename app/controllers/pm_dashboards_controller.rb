class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues
  
  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues = @project.pm_dashboard_issues.all
    @risks = params[:risk] ? @project.risks.find(params[:risk]).to_a : @project.risks.find(:all, :order => 'ref_number DESC')
    @members = @project.members.all(:order => "role_id")
    @project_scope = CustomField.find_by_name("Project Scope")
    @user_custom_fields = CustomField.find(:all, :conditions => "type = 'UserCustomField'")
    if !@project_scope.nil?
      @project_scope_value = @project.custom_values.find(:all, :conditions => "custom_field_id = #{@project_scope.id}")
    end
    @stakeholder_roles = Role.find(:all, :conditions => "name LIKE '%Clients%'")
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
