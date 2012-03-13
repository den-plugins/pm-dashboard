class CostMonitoringController < PmController
  menu_item :bottomline

  before_filter :get_project
  before_filter :authorize, :only => [:index]
  before_filter :role_check, :only => [:index]

  include PmDashboardsHelper
  include ResourceCostsHelper
  helper :resource_costs
  
  def index
    view = params[:view] || "week"
    @bac_hours = 0
    @bac_amount = display_by_billing_model.eql?("fixed") ? @project.project_contracts.all.sum(&:amount) : 0
    @budget_to_date, @actuals_to_date = 0, 0
    @contingency_amount = 0
    @project_budget = 0
    @estimate_to_complete = 0

    pfrom, afrom, pto, ato = @project.planned_start_date, @project.actual_start_date, @project.planned_end_date, @project.actual_end_date
    to = (ato || pto)
    if pfrom && to
      team = @project.members.project_team.all
      
      if view.casecmp("month") == 0
        reporting_period = (Date.today-1.month).end_of_month
        forecast_range = @months = get_months_range(pfrom, to)
        actual_range = get_months_range((afrom || pfrom), reporting_period)
        estimate_range = get_months_range((reporting_period+1.month).beginning_of_month, to)
      elsif view.casecmp("week") == 0
        reporting_period = (Date.today-1.week).end_of_week
        forecast_range = @weeks = get_weeks_range(pfrom, to)
        actual_range = get_weeks_range((afrom || pfrom), reporting_period)
        estimate_range = get_weeks_range((reporting_period+1.week).beginning_of_week, to)
      end
      
      @cost = @project.monitored_cost(forecast_range, actual_range, team)
      forecast_list = forecast_range.collect {|r| r.first }
      actual_list = actual_range.collect {|r| r.first }
      estimate_list = estimate_range.collect {|r| r.first }
      
      @cost.each do |k, v|
        @bac_hours += v[:budget_hours] if forecast_list.include?(k.to_date)
        if actual_list.include?(k.to_date)
          @budget_to_date += v[:budget_cost]
          @actuals_to_date += v[:actual_cost]
        end
        @estimate_to_complete += v[:budget_cost] if estimate_list.include?(k.to_date)
      end
      #@contingency_amount = @bac_amount.to_f * (@project.contingency.to_f/100)
      @contingency_amount = 0 #for now
      @project_budget = @bac_amount + @contingency_amount
    end
    
    render :update do |page|
      page.replace_html :bottomline_header, :partial => "cost_monitoring/theader"
      page.replace_html :bottomline_cost_content, :partial => "cost_monitoring/table"
    end if params[:view]
  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
