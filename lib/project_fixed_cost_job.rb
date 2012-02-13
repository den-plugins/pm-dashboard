class ProjectFixedCostJob < Struct.new(:project_id)
  include ResourceCostsHelper
  include ProjectBillabilityHelper
  include ResourceCostsHelper
  include PmDashboardsHelper

  def perform
    project = Project.find(project_id)
    updated_at = Time.now
    fixed_cost = load_fixed_cost_file
    bac_amount = project.project_contracts.all.sum(&:amount)
    actuals_to_date = 0
    contingency_amount = 0 # 0 for now
    project_budget = 0
    estimate_to_complete = 0
    pfrom, afrom, to = project.planned_start_date, project.actual_start_date, project.planned_end_date
    if pfrom && to
      team = project.members.project_team.all
      reporting_period = (Date.today-1.week).end_of_week
      forecast_range = get_weeks_range(pfrom, to)
      actual_range = get_weeks_range((afrom || pfrom), reporting_period)
      estimate_range = get_weeks_range((reporting_period+1.week).beginning_of_week, to)
      cost = project.monitored_cost(forecast_range, actual_range, team)
      actual_list = actual_range.collect {|r| r.first }
      estimate_list = estimate_range.collect {|r| r.first }
      cost.each do |k, v|
        if actual_list.include?(k.to_date)
          actuals_to_date += v[:actual_cost]
        end
        estimate_to_complete += v[:budget_cost] if estimate_list.include?(k.to_date)
      end
      project_budget = bac_amount + contingency_amount
    end
    estimate_at_complete = actuals_to_date + estimate_to_complete
    fixed_cost["fixed_cost_#{project_id}"] = {
      "cost_budget" => project_budget,
      "cost_forecast" => estimate_at_complete,
      "cost_actual" => actuals_to_date,
      "updated_at" => updated_at
    }
    File.open( "#{RAILS_ROOT}/config/fixed_cost.yml", 'w' ) do |out|
      YAML.dump( fixed_cost, out )
    end
  end

  def load_fixed_cost_file
    if File.exists?("#{RAILS_ROOT}/config/fixed_cost.yml")
      if file = YAML.load(File.open("#{RAILS_ROOT}/config/fixed_cost.yml"))
        fixed_cost = file
      else
        fixed_cost = {}
      end
    else
     fixed_cost = {}
    end
  end

end
