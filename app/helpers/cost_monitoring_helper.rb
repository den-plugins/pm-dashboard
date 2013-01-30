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

  def cost_compute_forecasted_hours_with_capped_allocation(week, resources, acctg)
    from, to = week.first, week.last
    resources.sum {|a| a.capped_days_and_cost((from..to), nil, false, acctg) * 8}
  end

  def cost_compute_forecasted_hours_with_capped_allocation_report(week, res_man, resources, acctg, detail=false)
    from, to = week.first, week.last
    user = resources.first.user
    available = user.available_hours(week.first, week.last, user.location)/8
    total_forecast = resources.sum {|a| a.capped_days_and_cost_report((from..to), res_man, nil, false, acctg, detail)}
    percent = "%.2f" % (total_forecast / available * 100).to_f
    available_hours = available * 8
    forcasted_hours = total_forecast * 8
    variance = available_hours - forcasted_hours
    if percent.to_f > 0
      res_man.info(",,,,, #{percent}, #{total_forecast}, #{total_forecast * 8}, #{available * 8}, #{variance}") if detail
      res_man.info("#{user.lastname}, #{user.firstname},,#{user.location},, #{percent}, #{total_forecast}, #{forcasted_hours}, #{available_hours}, #{variance}") if !detail
    else
      res_man.info("#{user.name}, , #{user.location},, #{0},,,, #{available_hours}, #{0}") if detail
      res_man.info("#{user.lastname}, #{user.firstname}, , #{user.location},, #{0},,, #{available_hours}, #{available_hours}") if !detail
    end
    return total_forecast
  end
end

