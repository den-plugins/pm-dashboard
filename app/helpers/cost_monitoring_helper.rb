module CostMonitoringHelper

  def cost_compute_actual_cost(week, resources, acctg=nil)
    from, to= week.first, (week.last.wday.eql?(5) ? (week.last+2.days) : week.last)
    resources.sum {|a| (a.actual_cost_per_resource(from, to, acctg, true))}
  end
  
  def cost_compute_forecasted_cost_without_contingency(week, resources, acctg, project=@project)
    from, to = week.first, week.last
    bac_amount = resources.sum {|a| a.days_and_cost_with_sow_rate((from..to), false, acctg).last}
    total_budget = bac_amount.to_f
  end
  
  def cost_compute_forecasted_hours(week, resources, acctg)
    from, to = week.first, week.last
    resources.sum {|a| a.days_and_cost((from..to), nil, false, acctg) * 8}
  end

  def cost_compute_forecasted_hours_with_capped_allocation(week, resources, acctg)
    from, to = week.first, week.last
    resources.sum {|a| a.capped_days_and_cost((from..to), nil, false, acctg) * 8}
  end

end

