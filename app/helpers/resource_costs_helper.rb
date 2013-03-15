module ResourceCostsHelper

  def get_days(from, to)
    if from && to
      days = []
      (from..to).each do |day|
        days << (day..day)
      end
      days
    end
  end

  def get_weeks(start_date, end_date)
    unless start_date.nil? or end_date.nil?
      start_date.weeks_ago end_date
    end
  end
  
  def get_weeks_range(from, to)
    if from && to
      start_date, end_date = from, to
      weeks = []
      # if from/to falls on a weekend, mon/fri is set to self (date)
      until ((from..to).to_a & (start_date..end_date).to_a).empty?
        mon = if from.wday.eql?(0) || from.wday.eql?(6)
                       from
                     else
                       from.eql?(start_date) ? start_date : from.monday
                     end
        fri = if from.wday.eql?(0) || from.wday.eql?(6)
                  from
                 else
                   mon.monday+4.days
                 end
        weeks << (mon .. fri)
        from = mon.next_week
      end
      weeks
    end
  end

  def get_weeks_range_with_weekend(from, to)
    if from && to
      start_date, end_date = from, to
      weeks = []
      # if from/to falls on a weekend, mon/fri is set to self (date)
      until ((from..to).to_a & (start_date..end_date).to_a).empty?
        mon = if from.wday.eql?(0) || from.wday.eql?(6)
                from
              else
                from.eql?(start_date) ? start_date : from.monday
              end
        sun = if mon.monday < to && to < mon.monday + 6.days
                to
              else
                mon.monday + 6.days
              end

        weeks << (mon .. sun)
        from = mon.next_week
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
    if from.eql? to
      s = from.to_date.strftime("%m/%d")
    else
      s = from.to_date.strftime("%m/%d") << " - " << to.to_date.strftime("%m/%d")
    end
  end
  
  def hnum(number)
    number_with_delimiter "%0.2f" % number.to_f
  end
  
  # computations
  def compute_days_and_cost(member, range, rate, acctg='Billable')
    mrate = (rate && rate.eql?('sow_rate')) ? daily_rate(member.sow_rate) : daily_rate(member.internal_rate)
    member.days_and_cost(range, mrate, false, acctg)
  end
  
  def compute_totals_per_column(project, per_column, total_cost)
    total_with_contingency = (total_cost * project.contingency.to_f)/100
    actual_total = total_cost + total_with_contingency
    cumulative_total = get_cumulative_total(per_column, actual_total).to_f
    [total_cost, total_with_contingency, actual_total, cumulative_total]
  end
  
  def allocation_color_class(total, is_shadowed=false, non_billable=false)
    if is_shadowed
      "lgray"
    elsif non_billable
      "lyellow"
    else
      return "" if total.eql?(0)
      total > 2.5 ? "lgreen" : ("lblue" if total <= 2.5)
    end
  end
  
  def collection_of_allocation_type(f)
    if @project.accounting_type.nil? || @project.accounting_type.downcase == "non-billable"
      f.select :resource_type, ResourceAllocation::TYPES.select {|t| t[0].eql?('Non-billable')}, {}, {:style => "width: 124px; margin: 0px"}
    elsif @project.accounting_type.downcase == "billable"
      f.select :resource_type, ResourceAllocation::TYPES, {}, {:style => "width: 124px; margin: 0px"}
    end
  end
  
  def collection_of_allocation_location(f, allocation)
    loc_options = @locations.sort.collect {|p| [ p[1], p[0] ] }
    if allocation.new_record?
      loc_select = (loc=@member.user.location) ? loc_options.detect {|s| s[0].downcase.eql?(loc.downcase)} : nil
    else
      loc_select = allocation.location
    end
    f.select :location, loc_options, {:selected => loc_select}, {:style => "width: 124px; margin: 0px;"}
  end
end
