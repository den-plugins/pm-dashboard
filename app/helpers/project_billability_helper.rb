module ProjectBillabilityHelper

  def compute_labor_hours(week, resources)
    allocated = resources.select {|r| r.billable?(week.first, week.last)}
    8 * allocated.sum{|a| a.days_and_cost(week, nil, false)}
  end
  
  def compute_forecasted_hours(week, resources)
    from, to = week.first, week.last
    allocated = resources.select {|r| r.billable?(from, to)}
    allocated.sum {|a| a.days_and_cost((from..to), nil, false) * 8}
  end
  
  def compute_actual_hours(week, resources)
    from, to= week.first, (week.last.wday.eql?(5) ? (week.last+2.days) : week.last)
    allocated = resources.select {|r| r.billable?(from, to)}
    allocated.sum {|a| a.spent_time(from, to, true)}
  end
  
  def compute_percent_to_date(forecast, actual)
    if forecast.eql?(0)
      "%0.2f" % 0
    else
      "%0.2f" % ((actual.to_f/forecast.to_f)*100)
    end
  end
end
