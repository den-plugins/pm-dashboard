class ProjectBillabilityController < PmController
  menu_item :billability
  helper :resource_costs
  include ProjectBillabilityHelper

  before_filter :get_project
  before_filter :authorize
  before_filter :role_check

  def index
    @project_resources  = @project.members.select(&:billable?)
    if request.xhr?
      update_project_billability
    else
      handler = ProjectBillabilityJob.new(@project.id)
      @job = Delayed::Job.find_by_handler(handler.to_yaml)
      @job = nil if @job and @job.run_at.eql?(Time.parse("12am") + 1.day)
      @billability = load_billability_file(@project.id)
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
        @billability = load_billability_file(@project.id)
        handler = ProjectBillabilityJob.new(@project.id)
        @job = Delayed::Job.find(:first,
              :conditions => ["handler = ? AND run_at <> ?", "#{handler.to_yaml}", (Time.parse("12am") + 1.day)])
        enqueue_billability_job(handler) if @project.planned_end_date && @project.planned_start_date
      else
        @billability = load_billability_file(@project.id)
      end
    else
      @billability = load_billability_file(@project.id)
    end

    render(:update) do |p|
      p.replace_html "billability_list", :partial => 'project_billability/list'
    end if params[:view]
    render(:update) do |p|
      p.replace_html :keep_loading, :partial => 'project_billability/keep_loading'
    end if params[:processing] || params[:refresh]
  end

  def enqueue_billability_job(handler)
    unless @job
      puts "enqueuing billability job..."
      @job = Delayed::Job.enqueue handler
    end
  end
end
