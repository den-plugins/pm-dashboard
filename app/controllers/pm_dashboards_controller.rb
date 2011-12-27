class PmDashboardsController < ApplicationController

  menu_item :dashboard, :only => :index
  helper :risks
  helper :project_billability
  helper :resource_costs
  helper :project_billability
  helper :pm_dashboard_issues
  
  before_filter :get_project, :only => [:index, :load_chart]
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
    
    @project_resources  = @project.members.all
  end

  def load_chart
    if params[:chart] == "burndown_chart"
      @current_sprint = @project.current_active_sprint
      @burndown_chart = (@current_sprint and BurndownChart.sprint_has_started(@current_sprint.id))? BurndownChart.new(@current_sprint) : nil
    elsif params[:chart] == "billability_chart"
      @project_resources  = @project.members.select(&:billable?)
    elsif params[:chart] == "cost_monitoring_chart"
      @cost_budget = params[:cost_budget].to_f
      @cost_forecast = params[:cost_forecast].to_f
      @cost_actual = params[:cost_actual].to_f
    end
    render :update do |page|
      page.replace_html "show_#{params[:chart]}".to_sym, :partial => "charts/#{params[:chart]}"
    end
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
