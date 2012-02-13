class ProjectBillabilityController < ApplicationController
  
  menu_item :billability
  
  helper :pm_dashboards
  helper :resource_costs
  
  before_filter :get_project
  before_filter :authorize
  
  def index
    @project_resources  = @project.members.select(&:billable?)
    if request.xhr?
      update_project_billability
    else
      handler = ProjectBillabilityJob.new(@project.id)
      @job = Delayed::Job.find_by_handler(handler.to_yaml)
      load_billability_file
      enqueue_billability_job(handler) if @billability.nil? || @billability.empty?
    end
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def update_project_billability
    @job = Delayed::Job.find_by_id(params[:job_id])
    if @job.nil?
      if params[:refresh]
        load_billability_file
        handler = ProjectBillabilityJob.new(@project.id)
        @job = Delayed::Job.find_by_handler(handler.to_yaml)
        enqueue_billability_job(handler) if @project.planned_end_date && @project.planned_start_date
      else
        load_billability_file
      end
    else
      load_billability_file
    end
    
    render(:update) do |p|
      p.replace_html "billability_list", :partial => 'project_billability/list'
    end if params[:view]
    render(:update) do |p|
      p.replace_html :keep_loading, :partial => 'project_billability/keep_loading'
    end if params[:processing] || params[:refresh]
  end

  def load_billability_file
    if File.exists?("#{RAILS_ROOT}/config/billability.yml")
      if file = YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))
        @billability = file["billability_#{@project.id}"]
      else
        @billability = {}
      end
    else
     @billability = {}
    end
  end

  def enqueue_billability_job(handler)
    unless @job
      puts "enqueuing billability job..."
      @job = Delayed::Job.enqueue handler
    end
  end

end
