class PmDashboardsController < PmController

  menu_item :dashboard, :only => :index
  helper :risks
  helper :project_billability
  helper :resource_costs
  helper :project_billability
  helper :pm_dashboard_issues
  include PmDashboardsHelper
  
  before_filter :get_project, :only => [:index, :load_chart, :reload_billability, :reload_fixed_cost]
  before_filter :authorize, :only => [:index]
  before_filter :role_check_client, :only => [:index]
  
  def index
    @highlights = @project.weekly_highlights
    @key_risks ||= @project.risks.key
    @key_issues ||= @project.pm_dashboard_issues.key
    @issues = @project.pm_dashboard_issues
    @project_team = @project.members.project_team
    @milestones = Version.find(:all, :conditions => ["project_id=? and effective_date < ?", @project, Date.today], :order => "effective_date DESC", :limit => 2) +
                                  Version.find(:all, :conditions => ["project_id=? and effective_date >= ?", @project, Date.today], :order => "effective_date ASC", :limit => 4)
    @milestones = @milestones.sort {|a, b| a[:effective_date] <=> b[:effective_date]}
    @milestones = @milestones.reverse {|v| v.effective_date}
    @current_sprint = @project.current_version
    @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    
    billing_model = display_by_billing_model
    if @project.planned_end_date && @project.planned_start_date
      handler = ProjectBillabilityJob.new(@project.id)
      @job = Delayed::Job.find(:first,
              :conditions => ["handler = ? AND run_at <> ?", "#{handler.to_yaml}", (Time.parse("12am") + 1.day)])
      load_billability_file
      enqueue_billability_job(handler) if @billability.nil? || @billability.empty?
    end
    if billing_model == "fixed"
      if @project.planned_start_date && (@project.actual_end_date || @project.planned_end_date)
        handler = ProjectFixedCostJob.new(@project.id)
        @job = Delayed::Job.find(:first,
              :conditions => ["handler = ? AND run_at <> ?", "#{handler.to_yaml}", (Time.parse("12am") + 1.day)])
        load_fixed_cost_file
        enqueue_fixed_cost_job(handler) if @fixed_cost.nil? || @fixed_cost.empty?
      else
        @fixed_cost = "none"
      end
    end
  end

  def load_chart
    if params[:chart] == "burndown_chart"
      @current_sprint = @project.current_active_sprint
      @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    elsif params[:chart] == "billability_chart"
    #@project_resources  = @project.members.select(&:billable?)
      load_billability_file
    elsif params[:chart] == "cost_monitoring_chart"
      @cost_budget = params[:cost_budget].to_f
      @cost_forecast = params[:cost_forecast].to_f
      @cost_actual = params[:cost_actual].to_f
    end
    render :update do |page|
      page.replace_html "show_#{params[:chart]}".to_sym, :partial => "charts/#{params[:chart]}"
    end
  end

  def reload_billability
    @job = Delayed::Job.find_by_id(params[:job_id])
    if params[:refresh]
      @job.destroy if !@job.nil?
      load_billability_file
      handler = ProjectBillabilityJob.new(@project.id)
      @job = Delayed::Job.find(:first,
            :conditions => ["handler = ? AND run_at <> ?", "#{handler.to_yaml}", (Time.parse("12am") + 1.day)])
      enqueue_billability_job(handler) if @project.planned_end_date && @project.planned_start_date
    else
      load_billability_file
    end
    
    render :update do |page|
      page.replace :billability_box, :partial => "pm_dashboards/load_billability"
    end
  end

  def reload_fixed_cost
    @job = Delayed::Job.find_by_id(params[:job_id])
    if @job.nil?
      if params[:refresh]
        load_fixed_cost_file
        handler = ProjectFixedCostJob.new(@project.id)
        @job = Delayed::Job.find(:first,
              :conditions => ["handler = ? AND run_at <> ?", "#{handler.to_yaml}", (Time.parse("12am") + 1.day)])
        enqueue_fixed_cost_job(handler)
      else
        load_fixed_cost_file
      end
    else
      load_fixed_cost_file
    end
    render :update do |page|
      page.replace :fixed_cost_box, :partial => "pm_dashboards/load_fixed_cost"
    end
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
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

  def load_fixed_cost_file
    if File.exists?("#{RAILS_ROOT}/config/fixed_cost.yml")
      if file = YAML.load(File.open("#{RAILS_ROOT}/config/fixed_cost.yml"))
        @fixed_cost = file["fixed_cost_#{@project.id}"]
      else
        @fixed_cost = {}
      end
    else
     @fixed_cost = {}
    end
  end

  def enqueue_billability_job(handler)
    if @job.blank?
      puts "enqueuing billability job..."
      @job = Delayed::Job.enqueue handler
    end
  end

  def enqueue_fixed_cost_job(handler)
    if @job.blank?
      puts "enqueuing fixed cost job..."
      @job = Delayed::Job.enqueue handler
    end
  end
  
  def role_check
    member = @project.members.find(:first, :conditions => ["user_id=?", User.current.id])
    @client = member if !User.current.admin? and (role=member.role) and role.name.downcase.include?('clients')
  end
  
end
