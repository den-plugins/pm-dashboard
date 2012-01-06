class ProjectBillabilityJob < Struct.new(:project_id)
  include ResourceCostsHelper
  include ProjectBillabilityHelper
  include ResourceCostsHelper
  include PmDashboardsHelper
  
  def perform
    project = Project.find(project_id)
    project_resources = project.members.select(&:billable?)
    views = ["week", "month"]
    billability = FileTest.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml")) : {}
    views.each do |view|
    first_time_entry = project.time_entries.find(:first, 
                                :select => "spent_on", 
                                :conditions => "hours > 0", 
                                :order => "spent_on ASC")
    actual_start = project.actual_start_date || (first_time_entry ? first_time_entry.spent_on : project.planned_start_date)
    actual_end = (Date.today - 1.week).end_of_week
    if view == "week"
      dates = get_weeks_range(actual_start, project.planned_end_date)
    elsif view == "month"
      dates = get_months_range(actual_start, project.planned_end_date)
    end
    billability_per_date = Array.new
    bill_total, dates_total = 0, 0
    per_date_totals = Hash.new
    total_forecast = 0.0
    total_actuals = 0.0
    total_percent_billability = 0.0

    dates.each_with_index do |date, dnum|
      per_date_totals[date.last.to_s] = Hash.new
      per_date_totals[date.last.to_s]["lh"] = compute_labor_hours(date, project_resources)
      per_date_totals[date.last.to_s]["fh"] = compute_forecasted_hours(date, project_resources)
      per_date_totals[date.last.to_s]["ah"] = compute_actual_hours(date, project_resources)

      bill = compute_percent_to_date per_date_totals[date.last.to_s]["fh"], 
                                                   per_date_totals[date.last.to_s]["ah"]
      
      total_forecast += per_date_totals[date.last.to_s]["fh"]
      total_actuals += per_date_totals[date.last.to_s]["ah"]
      if view == "week"
        billability_per_date << [date.last, bill.to_f] if date.last < (Date.today.monday + 4.days)
      elsif view == "month"
        billability_per_date << [date.last, bill.to_f] if date.last <= (Date.today.end_of_month)
      end
      unless (date.to_a & (actual_start..actual_end).to_a).empty?
        bill_total += bill.to_f
        dates_total += 1
      end
    end

    total_percent_billability = bill_total/dates_total
    if billability["billability_#{project.id}"].nil? || billability.empty?
      billability["billability_#{project.id}"] = {
        "per_#{view}_totals" => per_date_totals,
        "billability_per_#{view}" => billability_per_date,
        "total_percent_billability_#{view}" => total_percent_billability,
        "total_forecast" => total_forecast,
        "total_actuals" => total_actuals
      }
    else
      temp = {
        "per_#{view}_totals" => per_date_totals,
        "billability_per_#{view}" => billability_per_date,
        "total_percent_billability_#{view}" => total_percent_billability,
        "total_forecast" => total_forecast,
        "total_actuals" => total_actuals
      }
      billability["billability_#{project.id}"] = billability["billability_#{project.id}"].merge(temp)
    end
    File.open( "#{RAILS_ROOT}/config/billability.yml", 'w' ) do |out|
      YAML.dump( billability, out )
    end
    end
  end
end

