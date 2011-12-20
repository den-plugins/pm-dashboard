class ProjectInfoController < ApplicationController

  menu_item :info
  
  before_filter :get_project, :only => [:index, :add, :update, :destroy, :add_pm_position, :add_pm_role, :pm_member_add, :pm_member_edit]
  before_filter :authorize, :only => [:index, :add, :update, :destroy, :add_pm_position, :add_pm_role, :pm_member_add, :pm_member_edit]
  
  def index
    @stakeholders = @project.members.stakeholders
    if !@project.stakeholders.empty?
      @stakeholders.concat(@project.stakeholders.all)
    end
    @proj_team = @project.members.project_team

    @stakeholder_roles = RolesPositionsDefault::STAKEHOLDER_ROLES
    @proj_team_roles = RolesPositionsDefault::PROJ_TEAM_ROLES
    @proj_team_positions = RolesPositionsDefault::PROJ_TEAM_POS

    set_roles_pos @stakeholder_roles, @proj_team_roles, @proj_team_positions
  end

  def update
    if request.post? and !request.xhr?
      @project.validate_client = true
      psd, ped = params[:project][:planned_start_date].to_date, params[:project][:planned_end_date].to_date
      if @project.update_attributes(params[:project])
        if (psd.cwday == 6 || psd.cwday == 7) || (ped.cwday == 6 || ped.cwday == 7)
          flash[:warning] = "Cannot set weekends for planned start or end dates. Date is set to friday."
        end
        redirect_to_info
      else
        render :template => "project_info/edit_with_error"
      end
    else
      render :partial => "project_info/edit"
    end
  end

  def pm_member_edit
    bool = ((params[:classification].eql?("stakeholder"))? true : false)
    @positions = PmPosition.find(:all) #Positions created by PM
    @roles = PmRole.find(:all, :conditions => "for_stakeholder = #{bool}") #Roles created by PM
    @member = Member.find(params[:id])
    render :partial => "project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classification].to_sym}
  end

  def pm_member_update
    @positions = PmPosition.find(:all) #Positions created by PM
    bool = ((params[:classification].eql?("stakeholder"))? true : false)
    @roles = PmRole.find(:all, :conditions => "for_stakeholder = #{bool}") #Roles created by PM
    if request.post? and !request.xhr?
      @member = Member.find(params[:id]) 
      @project = @member.project

      if @member.update_attributes(params[:member])
        render(:update) {|page| page.replace_html "tr_#{params[:classif]}_#{@member.id}",
        {:partial => "project_info/pm_member_edit",
         :locals => {:member => @member}}}
      end
    else 
      if params[:classification]
        @project = Project.find(params[:project_id])
        render :partial => "project_info/pm_member_add", 
                      :locals => {:classification => params[:classification]}
      else
        @member = Member.find(params[:id]) 
        @project = @member.project

        if @member.update_attributes(params[:member])
          render(:update) {|page| page.replace_html "tr_#{params[:classif]}_#{@member.id}", 
          {:partial => "project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classif].to_sym}}}
        end
      end
    end
  end

  def pm_member_add
    member_ids = params[:project][:member_ids]
    if params[:classification].eql?("stakeholder")
      @project.stakeholders.clear
      member_ids.each do |id|
        if id.split("_").last.eql? "s"
          @stakeholder = Stakeholder.find(id.split("_").first)
          @project.stakeholders << @stakeholder
        end
      end
    end
    @project.members.each do |member|
      if member_ids.member?(member.id.to_s)
        member.update_attributes(params[:classification].to_sym => true)
      else
        member.update_attributes(params[:classification].to_sym => false)
      end
    end
    redirect_to_info
  end

  def pm_member_remove
    if request.post?
      @member = Member.find(params[:id])
      @project = @member.project

      if @member.update_attributes(params[:member])
        redirect_to_info
      end
    end
  end

  def update_role_pos
    if params[:no_accnt]
      @member = Stakeholder.find(params[:id])
      @project = Project.find(params[:project_id])
    else
      @member = Member.find(params[:id])
      @project = @member.project
    end

    role_or_pos = params[:member][params[:role_or_pos].to_sym]

    if role_or_pos.blank? or role_or_pos.eql?("Others")
      form_name = ((params[:role_or_pos].split("_")[1].eql?("role"))? "role" : "position")
      render(:update) {|page| page.replace_html "#{params[:role_or_pos].split('_')[1]}_#{params[:id]}", 
      {:partial => 'project_info/add_role_pos', :locals => {:form_name => form_name, 
      :classification => params[:classification].to_sym}}}
    else
      if @member.update_attributes(params[:member])
        redirect_to_info
      end
    end

  end

  def add_pm_position
    if params[:no_accnt]
      @member = Stakeholder.find(params[:id])
    else
      @member = Member.find(params[:id])
    end
    
    @position = PmPosition.new(params[:position])
    if @position.save
      bool = ((params[:classification].eql?("stakeholder") || @member.is_a?(Stakeholder))? true : false)
      @positions = PmPosition.find(:all) #Positions created by PM
      @roles = PmRole.find(:all, :conditions => "for_stakeholder = #{bool}") #Roles created by PM
      @member.update_attributes(:pm_pos_id => @position.id)
    end
    if params[:no_accnt]
      render(:update) {|page| page.replace_html "tr_stakeholder_#{@member.id}", 
          {:partial => "project_info/stakeholder_edit", 
           :locals => {:member => @member, :classification => :stakeholder}}}
    else
      render(:update) {|page| page.replace_html "tr_#{params[:classification]}_#{@member.id}", 
          {:partial => "project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classification].to_sym}}}
    end
  end

  def add_pm_role
    if params[:no_accnt]
      @member = Stakeholder.find(params[:id])
    else
      @member = Member.find(params[:id])
    end 
    @role = PmRole.new(params[:role])
    @role.check_stakeholder(@member)
    if @role.save
      bool = ((params[:classification].eql?("stakeholder") || @member.is_a?(Stakeholder))? true : false)
      @positions = PmPosition.find(:all) #Positions created by PM
      @roles = PmRole.find(:all, :conditions => "for_stakeholder = #{bool}") #Roles created by PM
      @member.update_attributes(:pm_role_id => @role.id)
    end
    if params[:no_accnt]
      render(:update) {|page| page.replace_html "tr_stakeholder_#{@member.id}", 
          {:partial => "project_info/stakeholder_edit", 
           :locals => {:member => @member, :classification => :stakeholder}}}
    else
      render(:update) {|page| page.replace_html "tr_#{params[:classification]}_#{@member.id}", 
          {:partial => "project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classification].to_sym}}}
    end
  end

  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_info
    redirect_to :controller => 'project_info', :action => 'index', :project_id => @project
  end

  def set_roles_pos(stakeholder_roles, proj_team_roles, proj_team_positions)
    stakeholder_roles.each do |r|
      @role = PmRole.find_by_name(r)
      if @role.nil?
        @role = PmRole.new(:name => r, :for_stakeholder => true)
        @role.save
      end
    end
  end

end
