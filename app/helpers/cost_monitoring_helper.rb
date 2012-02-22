module CostMonitoringHelper

  def cost_compute_actual_cost(week, resources, acctg=nil)
    from, to= week.first, (week.last.wday.eql?(5) ? (week.last+2.days) : week.last)
    resources.sum {|a| (a.spent_time(from, to, acctg, true) * a.internal_rate.to_f)}
  end
  
  def cost_compute_forecasted_cost_without_contingency(week, resources, acctg, project=@project)
    from, to = week.first, week.last
    bac_amount = resources.sum {|a| a.days_and_cost((from..to), (a.internal_rate.to_f * 8), false, acctg).last}
    total_budget = bac_amount.to_f
  end
  
  def cost_compute_forecasted_hours(week, resources, acctg)
    from, to = week.first, week.last
    resources.sum {|a| a.days_and_cost((from..to), nil, false, acctg) * 8}
  end
end
