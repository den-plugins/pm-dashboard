class AssumptionsController < ApplicationController
  
  helper :pm_dashboards
  
  before_filter :require_login
  before_filter :get_project, :only => [:add, :update, :destroy]
  before_filter :get_assumption, :only => [:update, :destroy]
  
  
  def add
    if request.post? and !request.xhr?
      @assumption = @project.assumptions.create(params[:assumption])
      if @assumption.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :assumptions
      else
        #redirect_to :action => 'add', :project_id => @project, :method => :get
        render :update, :layout => 'base' do |page|
          page.replace_html "assumptions-#{@project.id}", :partial => "pm_dashboards/assumptions/add"
        end
      end
    else
      @assumption = Assumption.new
      render :partial => "pm_dashboards/assumptions/add"
    end
  end
  
  def update
    if request.post? and !request.xhr?
      if @assumption.update_attributes(params[:assumption])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :assumptions
      else
        render :template => "pm_dashboards/assumptions/edit"
      end
    else
      render :partial => "pm_dashboards/assumptions/edit"
    end
  end
  
  def destroy
    if @assumption.destroy
      redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :assumptions
    end
  end
    
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_assumption
    @assumption = Assumption.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
