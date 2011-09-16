module ResourceCostsHelper

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      end_date.cweek - start_date.cweek
    end
  end

end
