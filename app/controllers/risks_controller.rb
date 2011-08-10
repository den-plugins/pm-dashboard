class RisksController < ApplicationController

  helper :pm_dashboards
  
  before_filter :require_login
  before_filter :get_project, :only => [:add, :update, :destroy]
  before_filter :get_risk, :only => [:update, :destroy]
  
  def add
    if request.get?
      @risk = Risk.new
      render :template => "pm_dashboards/risks/add" 
    else
      @risk = @project.risks.create(params[:risk])
      if @risk.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :risks
      else
        render :template => "pm_dashboards/risks/add" 
      end
    end
  end
  
  def update
    if request.get?
      render :template => "pm_dashboards/risks/edit"
    else
      if @risk.update_attributes(params[:risk])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :risks
      else
        render :template => "pm_dashboards/risks/edit"
      end
    end
  end
  
  def destroy
    if @risk.destroy
      redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :risks
    end
  end
    
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_risk
    @risk = Risk.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
