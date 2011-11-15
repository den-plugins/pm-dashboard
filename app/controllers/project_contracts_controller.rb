class ProjectContractsController < ApplicationController

  helper :pm_dashboards
  
  before_filter :require_login
  before_filter :get_project, :only => [:add, :update, :destroy]
  before_filter :get_project_contract, :only => [:update, :destroy]
  
  def add
    if request.get?
      @project_contract = ProjectContract.new
      render :template => "pm_dashboards/project_contracts/add" 
    elsif request.xhr?
      @project_contract = ProjectContract.new
      render :partial => "pm_dashboards/project_contracts/add" 
    else
      attachments = {:attached_files => params[:attachments]}
      @project_contract = @project.project_contracts.build(params[:project_contract].merge(attachments))
      if @project_contract.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_project_contracts
      else
        puts "----------" + @project_contract.errors.inspect + "----------"
        render :template => "pm_dashboards/project_contracts/add"
      end
    end
  end
  
  def update
    if request.get?
      render :template => "pm_dashboards/project_contracts/edit"
    elsif request.xhr?
      render :partial => "pm_dashboards/project_contracts/edit" 
    else
      if @project_contract.update_attributes(params[:project_contract])
        attachments = attach_files(@project_contract, params[:attachments])
        flash[:notice] = l(:notice_successful_update)
        flash[:warning] += " File format invalid. Must be PDF." if flash[:warning] && flash[:warning].include?("could not be saved")
        redirect_to_project_contracts
      else
        render :template => "pm_dashboards/project_contracts/edit"
      end
    end
  end

  def destroy
    if @project_contract.destroy
      redirect_to_project_contracts
    end
  end
    
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_project_contract
    @project_contract = ProjectContract.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_project_contracts
    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :project_contracts
  end
end
