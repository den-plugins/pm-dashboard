class ProjectBillabilityController < ApplicationController
  
  menu_item :billability
  
  helper :pm_dashboards
  helper :resource_costs
  
  before_filter :get_project
  before_filter :authorize
  
  def index
    @project_resources  = @project.members.select(&:billable?)
    update_project_billability
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def update_project_billability
    render(:update) do |p|
      p.replace_html "billability_list", :partial => 'project_billability/list'
    end if params[:view]
  end
end
