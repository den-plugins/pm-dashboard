class AssumptionsController < ApplicationController
  
  menu_item :assumptions
  
  helper :pm_dashboards
  
  before_filter :require_login
  before_filter :get_project
  before_filter :get_assumption, :only => [:update, :destroy]
  
  def index
    @assumption = Assumption.find(params[:id]) if params[:id]
    @project ||= @assumption.project
    @assumptions = params[:id] ? [@assumption] : @project.assumptions.find(:all, :order => 'ref_number DESC')
  end
  
  def add
    if request.get?
      @assumption = Assumption.new
      render :template => "assumptions/add"
    else
      @assumption = @project.assumptions.create(params[:assumption])
      if @assumption.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_assumptions
      else
        render :template => "assumptions/add"
      end
    end
  end
  
  def update
    if request.get?
      render :template => "assumptions/edit"
    else
      if @assumption.update_attributes(params[:assumption])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_assumptions
      else
        render :template => "assumptions/edit"
      end
    end
  end
  
  def destroy
    if @assumption.destroy
      redirect_to_assumptions
    end
  end
    
  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_assumption
    @assumption = Assumption.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_assumptions
    redirect_to :controller => 'assumptions', :project_id => @project
  end
end
