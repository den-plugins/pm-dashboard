module ResourceCostsHelper

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      start_date.weeks_ago end_date
    end
  end

  def get_months(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      (start_date .. end_date).map {|m| m.month}.uniq
    end
  end
  
  def get_cumulative_total(per_column, total)
    per_column.each_value do |col|
      total += col[2].to_f
    end
    total
  end

end
