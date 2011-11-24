module ResourceCostsHelper

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      start_date.weeks_ago end_date
    end
  end
  
  def get_weeks_range(from, to)
    if from && to
      start_date, end_date = from, to
      weeks = []
      for i in 0 .. from.weeks_ago(to) do
        mon = from.eql?(start_date) ? start_date : from.monday
        fri = from.weeks_ago(to).eql?(0) ? to : (mon.monday+4.days)
        weeks << (mon .. fri)
        from = mon + 1.week unless from.weeks_ago(to).eql?(0)
      end
      weeks
    end
  end
  
  def get_months(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      (start_date .. end_date).map {|m| m.beginning_of_month }.uniq
    end
  end
  
  def get_months_range(from, to)
    if from && to
      start_date, end_date = from, to
      months = []
      for m in 0 .. from.months_ago(to) do
        first = from.eql?(start_date) ? start_date : from.beginning_of_month
        last = from.months_ago(to).eql?(0) ? to : from.end_of_month
        months << (first .. last)
        from = first + 1.month unless from.months_ago(to).eql?(0)
      end
      months
    end
  end
  
  def get_cumulative_total(per_column, total)
    per_column.each_value do |col|
      total += col[2].to_f
    end
    total
  end
  
  def daily_rate(rate)
    rate.to_f * 8
  end
  
  def display_week(range)
    from, to = range.first, range.last
    s = "%s/" % from.mon + "%s" % from.day + " - " +
           "%s/" % to.mon + "%s" % to.day
  end
  
  # computations
  def compute_days_and_cost(member, range, rate)
    mrate = (rate && rate.eql?('internal_rate')) ? daily_rate(member.internal_rate) : daily_rate(member.sow_rate)
    member.days_and_cost(range, mrate)
  end
  
  def compute_totals_per_column(project, per_column, total_cost)
    total_with_contingency = (total_cost * project.contingency.to_f)/100
    actual_total = total_cost + total_with_contingency
    cumulative_total = get_cumulative_total(per_column, actual_total).to_f
    [total_cost, total_with_contingency, actual_total, cumulative_total]
  end
  
  def allocation_color_class(total)
    total >= 2.5 ? "lgreen" : ("lblue" if total < 2.5)
  end
end
