class PmDashboardsController < ApplicationController

  menu_item :dashboard, :only => :index
  helper :risks
  helper :project_billability
  helper :resource_costs
  helper :project_billability
  helper :pm_dashboard_issues
  include PmDashboardsHelper
  
  before_filter :get_project, :only => [:index, :load_chart, :reload_billability]
  before_filter :authorize, :only => [:index]
  
  def index
    @highlights = @project.weekly_highlights
    @key_risks ||= @project.risks.key
    @key_issues ||= @project.pm_dashboard_issues.key
    @issues = @project.pm_dashboard_issues
    
    @milestones = Version.find(:all, :conditions => ["project_id=? and effective_date < ?", @project, Date.today], :order => "effective_date DESC", :limit => 2) +
                                  Version.find(:all, :conditions => ["project_id=? and effective_date >= ?", @project, Date.today], :order => "effective_date ASC", :limit => 4)
    @milestones = @milestones.reverse {|v| v.effective_date}

    @current_sprint = @project.current_version
    @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    billing_model = display_by_billing_model
    if billing_model == "billability" || billing_model.nil?
      @project_resources  = @project.members.select(&:billable?)
      @billability = File.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))["billability_#{@project.id}"] : {}
      if @project.planned_end_date && @project.planned_start_date
        Delayed::Job.enqueue BillabilityJob.new(@project, @project_resources) if @billability.nil? || @billability.empty?
      end
    elsif billing_model == "fixed"
      @project_resources  = @project.members.all
    end
  end

  def load_chart
    if params[:chart] == "burndown_chart"
      @current_sprint = @project.current_active_sprint
      @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    elsif params[:chart] == "billability_chart"
      @project_resources  = @project.members.select(&:billable?)
      @billability = (FileTest.exists?("#{RAILS_ROOT}/config/billability.yml"))? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))["billability_#{@project.id}"] : {}
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
    @project_resources  = @project.members.select(&:billable?)
    if @project.planned_end_date && @project.planned_start_date && params[:refresh]
      Delayed::Job.enqueue BillabilityJob.new(@project, @project_resources)
    end
    @billability = (FileTest.exists?("#{RAILS_ROOT}/config/billability.yml"))? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))["billability_#{@project.id}"] : {}

    if params[:refresh] && @billability
      temp = YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml"))
      temp.delete("billability_#{@project.id}")
      File.open( "#{RAILS_ROOT}/config/billability.yml", 'w' ) do |out|
        YAML.dump( temp, out )
      end
      @billability = nil
    end
    
    render :update do |page|
      page.replace :billability_box, :partial => "pm_dashboards/load_billability"
    end
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
