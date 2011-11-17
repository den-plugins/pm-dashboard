class PmDashboardsController < ApplicationController
  include FaceboxRender
  
  helper :assumptions
  helper :milestone_plans
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues
  helper :resource_costs
  helper :highlights
  helper :attachments
  helper :project_billability
  include AttachmentsHelper
  include Redmine::Export::PDF

  before_filter :get_id, :only => [:index]
  before_filter :get_project, :only => [:index, :edit_project]
  before_filter :authorize, :only => [:index]
    
  def index
    @version = Version.find(params[:version_id]) if params[:version_id]
    @version.update_attribute(:state, params[:state]) if @version
    @project.update_days_overdue
    @assumptions ||= @project.assumptions.find(:all, :order => 'ref_number DESC')
    @issues ||= @project.pm_dashboard_issues.find(:all, :order => 'ref_number DESC')
    @risks ||= @project.risks.find(:all, :order => 'ref_number DESC')
    @project_contracts ||= @project.project_contracts.find(:all, :order => 'id DESC')

    @highlights = @project.weekly_highlights
    @key_risks ||= @project.risks.key
    @key_issues ||= @project.pm_dashboard_issues.key

    @stakeholders = @project.members.stakeholders
    
    if !@project.stakeholders.empty?
      @stakeholders.concat(@project.stakeholders.all)
    end
    
    @project_resources  = @project.members.select(&:billable?)
    @proj_team = @project.members.project_team
    update_resource_list if params[:tab].eql?('resource_costs')
    
    @user_custom_fields = CustomField.find(:all, :conditions => "type = 'UserCustomField'")

    @stakeholder_roles = RolesPositionsDefault::STAKEHOLDER_ROLES
    @proj_team_roles = RolesPositionsDefault::PROJ_TEAM_ROLES
    @proj_team_positions = RolesPositionsDefault::PROJ_TEAM_POS

    set_roles_pos @stakeholder_roles, @proj_team_roles, @proj_team_positions
    
    @versions = Version.find(:all, :conditions => ["project_id = ?", @project], :order => 'effective_date IS NULL, effective_date DESC')
    rescue
      render_404
  end
  
  def update_resource_list
    if params[:view] or params[:rate]
      render(:update) do |p| 
        p.replace_html "resource_members_content", :partial => 'pm_dashboards/resource_costs/list' 
      end
    end
  end
  
  # Edit @project
  def edit_project
    if request.post?
      @project.attributes = params[:project]
      @proj_team = @project.members.project_team
      if @project.save
        render :update do |page|
          page.redirect_to :action => :index, :project_id => @project, :tab => 'resource_costs'
        end
      else
        render :update do |page|
          page.replace_html :resource_costs_header , :partial => 'pm_dashboards/resource_costs/header'
        end
      end
    end
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
        when 'project_contracts'
          @project = ProjectContract.find(params[:q]).project
          @project_contracts = @project.project_contracts.find(params[:q]).to_a
      end
    end
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def get_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
  def set_roles_pos(stakeholder_roles, proj_team_roles, proj_team_positions)

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

  end
  
end
