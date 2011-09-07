class PmDashboardsController < ApplicationController
  helper :assumptions
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues

  before_filter :get_id, :only => [:index]
    
  def index
    @project = Project.find(params[:project_id]) if params[:project_id]
    @project.update_days_overdue
    @assumptions ||= @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues ||= @project.pm_dashboard_issues.find(:all, :order => 'ref_number DESC')
    @risks ||= @project.risks.find(:all, :order => 'ref_number DESC')
    
    # member list with pagination
    # @member_count = @project.members.count(:all)
    # @member_pages = Paginator.new self, @members_count, per_page_option, params['page']
    @members = @project.members.find :all, :order => "users.firstname"
    #        :limit  =>  @member_pages.items_per_page,
    #        :offset =>  @member_pages.current.offset
    
    @stakeholders = @project.members.find(:all, :order => "users.firstname", 
                                          :conditions => "stakeholder = true")
    if !@project.stakeholders.empty?
      @stakeholders.concat(@project.stakeholders.all)
    end

    @proj_team = @project.members.find(:all, :order => "users.firstname", 
                                       :conditions => "proj_team = true")
    
    @user_custom_fields = CustomField.find(:all, :conditions => "type = 'UserCustomField'")

    @stakeholder_roles = RolesPositionsDefault::STAKEHOLDER_ROLES
    @proj_team_roles = RolesPositionsDefault::PROJ_TEAM_ROLES
    @proj_team_positions = RolesPositionsDefault::PROJ_TEAM_POS

    set_roles_pos @stakeholder_roles, @proj_team_roles, @proj_team_positions
    
    rescue ActiveRecord::RecordNotFound
      render_404
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
