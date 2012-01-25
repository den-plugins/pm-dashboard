class CostMonitoringController < ApplicationController

  menu_item :bottomline
  before_filter :get_project
  before_filter :authorize, :only => [:index]

  helper :resource_costs
  
  def index
    @bac_amount, @bac_hours = 0, 0
    @budget_to_date, @actuals_to_date = 0, 0
    @contingency_amount = 0
    @project_budget = 0
    @estimate_to_complete = 0
    
    @highlights = @project.weekly_highlights
    highlight =  (@highlights[:current] || @highlights[:after_current] || @highlights[:posted_current] || @highlights[:posted_after_current])
    reporting_period = highlight ? highlight.created_at.beginning_of_month : nil

    from, to = @project.planned_start_date, @project.planned_end_date
    if from && to
      team = @project.members.project_team.all
      @months = get_months_range(from, to)
      forecast_range = from .. (Date.today-1.month).end_of_month
      to_complete_range = reporting_period .. to if reporting_period

      @mcost = @project.monitored_cost(@months, team)
      @mcost.each do |k, v|
        @bac_hours += v[:budget_hours]
        @bac_amount += v[:budget_cost]
        if forecast_range.include?(k.to_date)
          @budget_to_date += v[:budget_cost]
          @actuals_to_date += v[:actual_cost]
        end
        @estimate_to_complete += v[:budget_cost] if reporting_period && to_complete_range.include?(k.to_date)
      end
      @contingency_amount = @bac_amount.to_f * (@project.contingency.to_f/100)
      @project_budget = @bac_amount + @contingency_amount
    end
  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
