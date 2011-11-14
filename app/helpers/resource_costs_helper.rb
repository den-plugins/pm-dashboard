module ResourceCostsHelper

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      start_date.weeks_ago end_date
    end
  end
  
  def get_weeks_range(from, to)
    if from && to
      weeks = [(from .. (from.monday + 4.days))]
      from = from.monday + 1.week
      for i in 0 .. (from.weeks_ago(to)) do
        if (from.weeks_ago(to)).eql?(0)
          mon, fri = from.monday, to
        else
          mon, fri = from.monday, (from.monday + 4.days)
        end
        weeks << (mon .. fri)
        from = mon + 1.week
      end
      weeks
    end
  end

  def get_months(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      (start_date .. end_date).map {|m| m.beginning_of_month }.uniq
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

end
