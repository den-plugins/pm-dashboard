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

  def compute_forecasted_cost(week, resources, project=@project)
    from, to = week.first, week.last
#    allocated = resources.select {|r| r.billable?(from, to)}
    bac_amount = resources.sum {|a| a.days_and_cost((from..to), daily_rate(a.internal_rate), false).last}
    contingency_amount = bac_amount.to_f * (project.contingency.to_f/100)
    total_budget = bac_amount.to_f + contingency_amount.to_f
  end
  
  def compute_actual_hours(week, resources)
    from, to= week.first, (week.last.wday.eql?(5) ? (week.last+2.days) : week.last)
    allocated = resources.select {|r| r.billable?(from, to)}
    allocated.sum {|a| a.spent_time(from, to, true)}
  end

  def compute_actual_cost(week, resources)
    from, to= week.first, (week.last.wday.eql?(5) ? (week.last+2.days) : week.last)
    allocated = resources.select {|r| r.billable?(from, to)}
    allocated.sum {|a| (a.spent_time(from, to, true) * a.internal_rate.to_f)}
  end
  
  def compute_percent_to_date(forecast, actual)
    if forecast.eql?(0)
      "%0.2f" % 0
    else
      "%0.2f" % ((actual.to_f/forecast.to_f)*100)
    end
  end
  
  def cost_color_code_billability(percent)
    case
      when percent > 85; "green"
      when (80 ... 85) === percent; "yellow"
      when (0 ... 80) === percent; "red"
    end
  end
  
  def cost_color_code_fixed(contracts, forecasts)
    case contracts <=> forecasts
      when -1; "red"
      when 1; "green"
      when 0: "yellow"
    end
  end
  
  def cost_color_code_label(code)
    case code
      when "green"; "Good"
      when "yellow"; "Warning"
      when "red"; "Red Flag"
    end
  end

  def schedule_color_code
    if @project.planned_end_date && @project.actual_end_date
      (@project.actual_end_date < @project.planned_end_date)? "red" : "green"
    else
      "yellow"
    end
  end
end
