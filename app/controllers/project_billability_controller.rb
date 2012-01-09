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
    if @project.planned_end_date && @project.planned_start_date && params[:refresh]
      Delayed::Job.enqueue ProjectBillabilityJob.new(@project.id)
      temp = File.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml")) : {}
      temp.delete("billability_#{@project.id}")
      File.open( "#{RAILS_ROOT}/config/billability.yml", 'w' ) do |out|
        YAML.dump( temp, out )
      end
      @billability = nil
    else
      @billability = File.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))["billability_#{@project.id}"] : {}
    end
    render(:update) do |p|
      p.replace_html "billability_list", :partial => 'project_billability/list'
    end if params[:view]
    render(:update) do |p|
      p.replace_html :keep_loading, :partial => 'project_billability/keep_loading'
    end if params[:processing] || params[:refresh]
  end
end
