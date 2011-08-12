class ProjectInfoController < ApplicationController

  before_filter :get_project, :only => [:add, :update, :destroy]

  def add
    
  end

  def update
    if request.post? and !request.xhr?
      if @project.update_attributes(params[:project])
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
      end
    else 
      render :partial => "pm_dashboards/project_info/edit"
    end
  end

  def destroy

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

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
