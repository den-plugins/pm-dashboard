class ResourceAllocationsController < ApplicationController
  include FaceboxRender
  
  helper :pm_dashboards
  helper :resource_costs
  helper :project_billability
  
  before_filter :get_member
  before_filter :get_project
  
  def index
    if params[:cancel]
      render_updates
    else
      @resource_allocations = @member.resource_allocations
      respond_to do |format|
        format.html
        format.js { render_to_facebox :partial => "pm_dashboards/resource_allocations/index" }
      end
    end
  end
  
  # POST
  def add
    @resource_allocation = @member.resource_allocations.create(params[:resource_allocation])
    if @resource_allocation.errors.empty?
      render_updates
    else
       render :update do |page|
        page.insert_html :bottom, :allocation_show, :partial => 'pm_dashboards/resource_allocations/date_range', :locals => {:allocation => nil}
        page.replace_html :allocation_add, :partial => 'pm_dashboards/resource_allocations/add'
       end
   end
  end
  
  # POST
  def edit
    @resource_allocation = @member.resource_allocations.find(params[:id])
    if @resource_allocation.update_attributes(params[:allocation])
      render_updates
    else
      render :update do |page|
        page.replace "date_range_#{@resource_allocation.id}_edit", :partial => "pm_dashboards/resource_allocations/edit_form",
                                           :locals => {:allocation => @resource_allocation}
        page["date_range_#{@resource_allocation.id}_edit"].show
      end
    end
  end
  
  # POST
  def bulk_edit
    with_errors = []
    params[:resource_allocations].collect do |k,v|
      @resource_allocation = @member.resource_allocations.find(k)
      with_errors << @resource_allocation.errors.full_messages unless @resource_allocation.update_attributes(v)
    end
    @resource_allocation.errors.clear()
    
    if with_errors.empty?
      render_updates
    else
      with_errors.uniq.each {|e| @resource_allocation.errors.add_to_base e }
      render :update do |page|
        page.replace_html :allocation_edit, :partial => 'pm_dashboards/resource_allocations/edit'
      end
    end
  end
  
  def destroy
    resource_allocation = @member.resource_allocations.find(params[:id])
    resource_allocation.destroy
    render_updates
  end
  
  private
  def get_project
    get_member unless @member
    @project = Project.find(params[:project_id] || @member.project.id)
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_member
    @member = Member.find(params[:member_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def render_updates
    @proj_team = @project.members.project_team
    @resource_allocations = @member.resource_allocations
    @project_resources = @project.members.select(&:billable?)
    render :update do |page|
      page.replace "allocations_#{@member.id}", :partial => 'pm_dashboards/resource_allocations/index'
      page.replace_html :resource_costs_header , :partial => 'pm_dashboards/resource_costs/header'
      page.replace_html :resource_members_content, :partial => 'pm_dashboards/resource_costs/list'

      #replace tabs affected by resource_allocation change
      #page.replace_html "dashboard_header", :partial => 'pm_dashboards/dashboard_header'
      #page.replace_html "dashboard_cost_monitoring", :partial => 'pm_dashboards/project_billability/cost_monitoring_dashboard'
      #page.replace_html "dashboard_billability", :partial => 'pm_dashboards/project_billability/billability_dashboard'
      #page.replace_html "tab-content-billability", :partial => 'pm_dashboards/project_billability'
      #page.replace_html "billability_charts", :partial => 'pm_dashboards/billability_charts'
    end
  end
end
