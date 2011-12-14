class RisksController < ApplicationController

  menu_item :risks

  helper :pm_dashboards
  
  before_filter :require_login
  before_filter :get_project, :only => [:index, :add, :update, :destroy]
  before_filter :get_risk, :only => [:update, :destroy]
  before_filter :authorize

  def index
    @risk = Risk.find(params[:id]) if params[:id]
    @project ||= @risk.project
    @risks = params[:id] ? [@risk] : @project.risks.find(:all, :order => 'ref_number DESC')
  end
  
  def add
    if request.get?
      @risk = Risk.new
      render :template => "risks/add" 
    else
      @risk = @project.risks.create(params[:risk])
      if @risk.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_risks
      else
        render :template => "risks/add"
      end
    end
  end
  
  def update
    if request.get?
      render :template => "risks/edit"
    else
      if @risk.update_attributes(params[:risk])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_risks
      else
        render :template => "risks/edit"
      end
    end
  end
    
  def destroy
    if @risk.destroy
      redirect_to_risks
    end
  end
    
  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_risk
    @risk = Risk.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_risks
    redirect_to :controller => 'risks', :action => 'index', :project_id => @project
  end
end
