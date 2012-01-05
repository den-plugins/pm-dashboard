class BillabilityJob < Struct.new(:project_id)
  include ResourceCostsHelper
  include ProjectBillabilityHelper
  include ResourceCostsHelper
  include PmDashboardsHelper
  
  def perform
    project = Project.find(project_id)
    project_resources = project.members.select(&:billable?)
    billability = FileTest.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml")) : {}
    puts billability["billability_#{project.id}"]
    first_time_entry = project.time_entries.find(:first, 
                                :select => "spent_on", 
                                :conditions => "hours > 0", 
                                :order => "spent_on ASC")
    actual_start = project.actual_start_date || (first_time_entry ? first_time_entry.spent_on : project.planned_start_date)
    actual_end = (Date.today - 1.week).end_of_week
    weeks = get_weeks_range(actual_start, actual_end)
    forecast = compute_forecasted_hours((actual_start..actual_end), project_resources)
    actual = compute_actual_hours((actual_start..actual_end), project_resources)
    percent_sum = weeks.sum {|w| compute_percent_to_date(compute_forecasted_hours(w, project_resources), compute_actual_hours(w, project_resources)).to_f}
    billability_per_week = json_billability_per_week(project.planned_start_date, project.planned_end_date, project_resources)
    billability["billability_#{project.id}"] = {"forecast" => forecast, "actual" => actual, 
                                                "percent_sum" => percent_sum, 
                                                "billability_per_week" => billability_per_week}
    File.open( "#{RAILS_ROOT}/config/billability.yml", 'w' ) do |out|
      YAML.dump( billability, out )
    end
  end
end

