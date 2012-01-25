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
    
    reporting_period = (Date.today-1.month).end_of_month
    pfrom, afrom, to = @project.planned_start_date, @project.actual_start_date, @project.planned_end_date
    if pfrom && to
      team = @project.members.project_team.all
      @months = get_months_range(pfrom, to)
      actual_range = get_months_range((afrom || pfrom), reporting_period)
      estimate_range = get_months_range((reporting_period+1.month).beginning_of_month, to)

      @mcost = @project.monitored_cost(@months, actual_range, team)
      
      forecast_list = @months.collect {|r| r.first }
      actual_list = actual_range.collect {|r| r.first }
      estimate_list = estimate_range.collect {|r| r.first }
      
      @mcost.each do |k, v|
        if forecast_list.include?(k.to_date)
          @bac_hours += v[:budget_hours]
          @bac_amount += v[:budget_cost]
        end
        if actual_list.include?(k.to_date)
          @budget_to_date += v[:budget_cost]
          @actuals_to_date += v[:actual_cost]
        end
        puts "#{k} -- #{v.inspect}" if estimate_list.include?(k.to_date)
        @estimate_to_complete += v[:budget_cost] if estimate_list.include?(k.to_date)
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
