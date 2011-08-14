class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues

  before_filter :get_id, :only => [:index]
    
  def index

    @project = Project.find(params[:project_id])
    @assumptions ||= @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues ||= @project.pm_dashboard_issues.all
    @risks ||= @project.risks.find(:all, :order => 'ref_number DESC')
    @stakeholders = @project.members.find(:all, :order => "role_id", 
                                          :conditions => "stakeholder = true")
    @proj_team = @project.members.find(:all, :order => "role_id", 
                                       :conditions => "proj_team = true")
    @positions = PmPosition.find(:all) #Positions created by PM
    @roles = PmRole.find(:all) #Roles created by PM
    @user_custom_fields = CustomField.find(:all, :conditions => "type = 'UserCustomField'")
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  private
  
  def get_id
    @project = Project.find(params[:project_id])
    if params[:q]
      case params[:tab]
        when 'assumptions'; @assumptions = @project.assumptions.find(params[:q]).to_a
        when 'issues'; @issues = @project.pm_dashboard_issues.find(params[:q]).to_a
        when 'risks'; @risks = @project.risks.find(params[:q]).to_a
      end
    end
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
end
