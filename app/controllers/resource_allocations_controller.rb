class ResourceAllocationsController < ApplicationController
  include FaceboxRender
  
  helper :pm_dashboards
  before_filter :get_project, :only => [:index]
  before_filter :get_member, :only => [:index, :add, :edit]
  
  def index
    @resource_allocations = @member.resource_allocations
    respond_to do |format|
      format.html
      format.js { render_to_facebox :partial => "pm_dashboards/resource_allocations/index" }
      end
  end
  
  # POST
  def add
    @resource_allocation = @member.resource_allocations.create(params[:resource_allocation])
    if @resource_allocation.errors.empty?
      @resource_allocations = @member.resource_allocations
      render :update do |page|
        page.insert_html :bottom, :allocation_show, :partial => 'pm_dashboards/resource_allocations/date_range', :locals => {:allocation => @resource_allocation}
        page.replace_html :allocation_add, :partial => 'pm_dashboards/resource_allocations/add'
        page.replace_html :allocation_actions, :partial => 'pm_dashboards/resource_allocations/actions'
        page.replace_html :allocation_edit, :partial => 'pm_dashboards/resource_allocations/edit'
      end
    else
       render :update do |page|
        page.insert_html :bottom, :allocation_show, :partial => 'pm_dashboards/resource_allocations/date_range', :locals => {:allocation => nil}
        page.replace_html :allocation_add, :partial => 'pm_dashboards/resource_allocations/add'
       end
   end
  end
  
  # POST
  def edit
    with_errors = []
    params[:resource_allocations].collect do |k,v|
      @resource_allocation = @member.resource_allocations.find(k)
      with_errors << @resource_allocation.errors.full_messages unless @resource_allocation.update_attributes(v)
    end
    
    @project = @member.project
    @resource_allocations = @member.resource_allocations
    @resource_allocation.errors.clear()
    
    if with_errors.empty?
      render :update do |page|
        page.replace "allocations_#{@member.project.id}", :partial => 'pm_dashboards/resource_allocations/index'
      end
    else
      with_errors.uniq.each {|e| @resource_allocation.errors.add_to_base e }
      render :update do |page|
        page.replace_html :allocation_edit, :partial => 'pm_dashboards/resource_allocations/edit'
      end
    end
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
