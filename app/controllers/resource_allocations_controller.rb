class ResourceAllocationsController < ApplicationController
  include FaceboxRender
  
  helper :pm_dashboards
  helper :resource_costs
  
  before_filter :get_member, :except => [:multiple_allocations]
  before_filter :get_members, :only => [:multiple_allocations]
  before_filter :get_project, :except => [:multiple_allocations]
  before_filter :get_possible_locations
  before_filter :authorize
  
  def index
    if params[:cancel]
      render_updates(true)
    else
      @resource_allocations = @member.resource_allocations
      respond_to do |format|
        format.html
        format.js { render_to_facebox :partial => "resource_allocations/index" }
      end
    end
  end

  def multiple_allocations
    if params[:cancel]
      render_updates
    else
      respond_to do |format|
        format.html
        format.js { render_to_facebox :partial => "resource_allocations/multiple_allocations" }
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
        page.insert_html :bottom, "allocation_show_#{@member.id}".to_sym, :partial => 'resource_allocations/date_range', :locals => {:allocation => nil}
        page.replace_html "allocation_add_#{@member.id}", :partial => 'resource_allocations/add'
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
        page.replace "date_range_#{@resource_allocation.id}_edit", :partial => "resource_allocations/edit_form",
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
        page.replace_html "allocation_edit_#{@member.id}".to_sym, :partial => 'resource_allocations/edit'
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

  def get_members
    @project = Project.find(params[:project_id])
    @members = Member.find_all_by_id(params[:member_ids])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def get_possible_locations
    @locations = {}
    # locations currently static atm. TODO override enumeration model
    ["Manila", "Cebu", "US", "N/A"].each do |location|
      hlocation = Holiday::LOCATIONS.detect {|k,v| v.downcase.eql?(location.downcase)}
      @locations [hlocation[0]] = hlocation[1] if hlocation
    end
  end
  
  def render_updates(index_only=false)
    @resource_allocations = @member.resource_allocations
    if index_only
      render :update do |page|
        page.replace "allocations_#{@member.id}", :partial => 'resource_allocations/index'
      end
    else
      @proj_team = @project.members.project_team
      @project_resources = @project.members.select(&:billable?)
      render :update do |page|
        page.replace "allocations_#{@member.id}", :partial => 'resource_allocations/index'
        page.replace_html :resource_costs_header , :partial => 'resource_costs/header'
        page.replace_html :resource_members_content, :partial => 'resource_costs/list'
      end
    end
  end
end
