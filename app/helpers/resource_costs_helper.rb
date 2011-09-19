module ResourceCostsHelper

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      end_date.cweek - start_date.cweek
    end
  end

  def get_months(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      (start_date .. end_date).map {|m| m.month}.uniq
    end
  end
  
  def get_cumulative_total(per_week, total)
    per_week.each_value do |week|
      total += week[2].to_f
    end
    total
  end

end
