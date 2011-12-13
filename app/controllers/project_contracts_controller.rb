class ProjectContractsController < ApplicationController
  
  menu_item :contracts
  
  helper :pm_dashboards
  helper :attachments
  include AttachmentsHelper
  include Redmine::Export::PDF
  
  before_filter :require_login
  before_filter :get_project, :only => [:index, :add, :update, :destroy]
  before_filter :get_project_contract, :only => [:update, :destroy]
  
  def index
    @project_contracts ||= @project.project_contracts.find(:all, :order => 'id DESC')
  end
    
  def add
    if request.get?
      @project_contract = ProjectContract.new
      render :template => "project_contracts/add"
    elsif request.xhr?
      @project_contract = ProjectContract.new
      render :partial => "project_contracts/add"
    else
      attachments = {:attached_files => params[:attachments]}
      @project_contract = @project.project_contracts.create(params[:project_contract].merge(attachments))
      if @project_contract.errors.empty?
        flash[:notice] = l(:notice_successful_create)
        redirect_to_project_contracts
      else
        render :template => "project_contracts/add"
      end
    end
  end
  
  def update
    if request.get?
      render :template => "project_contracts/edit"
    elsif request.xhr?
      render :partial => "project_contracts/edit"
    else
      attachments = {:attached_files => params[:attachments]}
      if @project_contract.update_attributes(params[:project_contract].merge(attachments))
        flash[:notice] = l(:notice_successful_update)
        redirect_to_project_contracts
      else
        render :template => "project_contracts/edit"
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
    redirect_to :controller => 'project_contracts', :project_id => @project
  end
end
