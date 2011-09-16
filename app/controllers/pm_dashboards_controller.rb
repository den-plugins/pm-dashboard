class PmDashboardsController < ApplicationController
  include FaceboxRender
  
  helper :assumptions
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues
  helper :resource_costs

  before_filter :get_id, :only => [:index]
    
  def index
    @project = Project.find(params[:project_id]) if params[:project_id]
    @project.update_days_overdue
    @assumptions ||= @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues ||= @project.pm_dashboard_issues.find(:all, :order => 'ref_number DESC')
    @risks ||= @project.risks.find(:all, :order => 'ref_number DESC')
    
    @key_risks ||= @project.risks.find(:all, :limit => 5, :order => 'ref_number DESC')
    @key_issues ||= @project.pm_dashboard_issues.find(:all, :limit => 5, :order => 'ref_number DESC')

    @stakeholders = @project.members.stakeholders
    
    if !@project.stakeholders.empty?
      @stakeholders.concat(@project.stakeholders.all)
    end

    @proj_team = @project.members.project_team
    
    update_resource_list if params[:tab].eql?('resource_costs')
    
    @user_custom_fields = CustomField.find(:all, :conditions => "type = 'UserCustomField'")

    @stakeholder_roles = RolesPositionsDefault::STAKEHOLDER_ROLES
    @proj_team_roles = RolesPositionsDefault::PROJ_TEAM_ROLES
    @proj_team_positions = RolesPositionsDefault::PROJ_TEAM_POS

    set_roles_pos @stakeholder_roles, @proj_team_roles, @proj_team_positions
    
    @releases = Release.find_all_by_project_id(@project)
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def update_resource_list
    if params[:view] or params[:rate]
      render(:update) {|p| p.replace_html "resource_members_content", :partial => 'pm_dashboards/resource_costs/list' }
    end
  end
  
  private
  
  def get_id
    if params[:q]
      case params[:tab]
        when 'assumptions'
          @project = Assumption.find(params[:q]).project
          @assumptions = @project.assumptions.find(params[:q]).to_a
        when 'issues'
          @project = PmDashboardIssue.find(params[:q]).project
          @issues = @project.pm_dashboard_issues.find(params[:q]).to_a
        when 'risks'
          @project = Risk.find(params[:q]).project
          @risks = @project.risks.find(params[:q]).to_a
      end
    end
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def set_roles_pos(stakeholder_roles, proj_team_roles, proj_team_positions)
    #----generate default data for positions and roles------
    #----so naughty :P--------------------------------------

    stakeholder_roles.each do |r|
      @role = PmRole.find_by_name(r)
      if @role.nil?
        @role = PmRole.new(:name => r, :for_stakeholder => true)
        @role.save
      end
    end

    proj_team_roles.each do |r|
      @role = PmRole.find_by_name(r)
      if @role.nil?
        @role = PmRole.new(:name => r)
        @role.save
      end
    end

    proj_team_positions.each do |p|
      @pos = PmPosition.find_by_name(p)
      if @pos.nil?
        @pos = PmPosition.new(:name => p)
        @pos.save
      end
    end

    #-------------------------------------------------------
  end
  
end
