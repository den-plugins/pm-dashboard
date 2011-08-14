class ProjectInfoController < ApplicationController

  before_filter :get_project, :only => [:add, :update, :destroy, :add_pm_position, :add_pm_role]

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

  def pm_member_add
    if request.post? and !request.xhr?
      @member = Member.find(params[:id]) 
      @project = @member.project

      if @member.update_attributes(params[:member])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
      end
    else 
      @project = Project.find(params[:project_id])
      render :partial => "pm_dashboards/project_info/pm_member_add", 
              :locals => {:classification => params[:classification]} 
    end
  end

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
    @member = Member.find(params[:id]) 
    @project = @member.project

    if params[:member][params[:role_or_pos].to_sym].blank?
      form_name = ((params[:role_or_pos].split("_")[1].eql?("role"))? "role" : "position")
      render(:update) {|page| page.replace_html "#{params[:role_or_pos].split('_')[1]}_#{params[:id]}", {:partial => 'pm_dashboards/project_info/add_role_pos', :locals => {:form_name => form_name}}}
    else
      if @member.update_attributes(params[:member])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
      end
    end

  end

  def add_pm_position
    @member = Member.find(params[:member_id]) 
    @position = PmPosition.new(params[:position])
    if @position.save
      @member.update_attributes(:pm_pos_id => @position.id)
    end
    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
  end

  def add_pm_role
    @member = Member.find(params[:member_id]) 
    @role = PmRole.new(params[:role])
    if @role.save
      @member.update_attributes(:pm_role_id => @role.id)
    end
    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
