class ResourceCostsController < ApplicationController
  include FaceboxRender
  
  helper :pm_dashboards
  before_filter :get_project, :only => [:allocation]
  before_filter :get_member, :only => [:allocation, :add, :edit]
  
  # all methods and views related to this controller is not yet final 
  # (slash still work in progress)
  # so don't get too shocked if bugs appear somewhere :)
  
  def allocation
    @resource_allocations = @member.resource_allocations
    action =@resource_allocations.nil? ? 'add' : 'edit'
    respond_to do |format|
      format.html
      format.js { render_to_facebox :template => "pm_dashboards/resource_allocations/#{action}" }
      end
  end
  
  # POST
  def add
    params[:resource_allocations].collect do |k,v|
      allocation = @member.resource_allocations.find(k)
      if allocation.create(v)
        flash[:notice] = l(:notice_successful_update)
      else
         flash[:notice] = "Error in saving resource allocations for #{@member.name}."
      end
    end
    redirect_to :controller => 'pm_dashboards', :action => 'index', :tab => 'resource_costs', :project_id => @member.project
  end
  
  # POST
  def edit
    params[:resource_allocations].collect do |k,v|
      allocation = @member.resource_allocations.find(k)
      if allocation.update_attributes(v)
        flash[:notice] = l(:notice_successful_update)
      else
         flash[:notice] = "Error in saving resource allocations for #{@member.name}."
      end
    end
    redirect_to :controller => 'pm_dashboards', :action => 'index', :tab => 'resource_costs', :project_id => @member.project
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_member
    @member = Member.find(params[:member_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
