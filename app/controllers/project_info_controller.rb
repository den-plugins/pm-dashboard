class ProjectInfoController < ApplicationController

  before_filter :get_project, :only => [:add, :update, :destroy, :add_pm_position, :add_pm_role, :pm_member_add, :pm_member_edit]

  def update
    if request.post? and !request.xhr?
      if @project.update_attributes(params[:project])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
      else
        render :template => "pm_dashboards/project_info/edit_with_error"
      end
    else 
      render :partial => "pm_dashboards/project_info/edit"
    end
  end

  def pm_member_edit
    @positions = PmPosition.find(:all) #Positions created by PM
    @roles = PmRole.find(:all) #Roles created by PM
    @member = Member.find(params[:id])
    render :partial => "pm_dashboards/project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classification].to_sym}
  end

  def pm_member_update
    if request.post? and !request.xhr?
      @member = Member.find(params[:id]) 
      @project = @member.project

      if @member.update_attributes(params[:member])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
      end
    else 
      if params[:classification]
        @project = Project.find(params[:project_id])
        render :partial => "pm_dashboards/project_info/pm_member_add", 
                      :locals => {:classification => params[:classification]}
      else
        @member = Member.find(params[:id]) 
        @project = @member.project

        if @member.update_attributes(params[:member])
          render(:update) {|page| page.replace_html "tr_#{params[:classif]}_#{@member.id}", 
          {:partial => "pm_dashboards/project_info/pm_member_edit", 
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
    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
  end

#  "#{params[:classification].downcase.sub(' ', '_')}_#{@project.id}"

  def pm_member_remove
    if request.post?
      @member = Member.find(params[:id])
      @project = @member.project

      if @member.update_attributes(params[:member])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
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
      {:partial => 'pm_dashboards/project_info/add_role_pos', :locals => {:form_name => form_name, 
      :classification => params[:classification].to_sym}}}
    else
      if @member.update_attributes(params[:member])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
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
      @positions = PmPosition.find(:all) #Positions created by PM
      @roles = PmRole.find(:all) #Roles created by PM
      @member.update_attributes(:pm_pos_id => @position.id)
    end
#    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
    if params[:no_accnt]
      render(:update) {|page| page.replace_html "tr_stakeholder_#{@member.id}", 
          {:partial => "pm_dashboards/project_info/stakeholder_edit", 
           :locals => {:member => @member, :classification => :stakeholder}}}
    else
      render(:update) {|page| page.replace_html "tr_#{params[:classification]}_#{@member.id}", 
          {:partial => "pm_dashboards/project_info/pm_member_edit", 
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
    if @role.save
      @positions = PmPosition.find(:all) #Positions created by PM
      @roles = PmRole.find(:all) #Roles created by PM
      @member.update_attributes(:pm_role_id => @role.id)
    end
    if params[:no_accnt]
      render(:update) {|page| page.replace_html "tr_stakeholder_#{@member.id}", 
          {:partial => "pm_dashboards/project_info/stakeholder_edit", 
           :locals => {:member => @member, :classification => :stakeholder}}}
    else
      render(:update) {|page| page.replace_html "tr_#{params[:classification]}_#{@member.id}", 
          {:partial => "pm_dashboards/project_info/pm_member_edit", 
           :locals => {:member => @member, :classification => params[:classification].to_sym}}}
    end
#    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
  end

#  def update_remarks
#    @member = Member.find(params[:id])
#    render :partial => 'pm_dashboards/project_info/edit_remarks'
#  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
