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

    from, to = @project.planned_start_date, @project.planned_end_date
    if from && to
      months = get_months_range(from, to)
      current_range = from .. (Date.today-1.month).end_of_month
      team = @project.members.project_team.all
      @mcost = @project.monitored_cost(months, team)
      @mcost.each do |k, v|
        @bac_hours += v[:budget_hours]
        @bac_amount += v[:budget_cost]
        if current_range.include?(k.to_date)
          @budget_to_date += v[:budget_cost]
          @actuals_to_date += v[:actual_cost]
        end
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
