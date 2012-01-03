class BillabilityJob < Struct.new(:project, :project_resources)
  include ResourceCostsHelper
  include ProjectBillabilityHelper
  
  def perform
    billability = FileTest.exists?("#{RAILS_ROOT}/config/billability.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/billability.yml")) : {}
    puts billability
    first_time_entry = project.time_entries.find(:first, 
                                :select => "spent_on", 
                                :conditions => "hours > 0", 
                                :order => "spent_on ASC")
    actual_start = project.actual_start_date || (first_time_entry ? first_time_entry.spent_on : project.planned_start_date)
    actual_end = (Date.today - 1.week).end_of_week
    weeks = get_weeks_range(actual_start, actual_end)
    forecast = compute_forecasted_hours((actual_start..actual_end), project_resources)
    billability["billability_#{project.id}"] = {"forecast" => forecast}
    File.open( "#{RAILS_ROOT}/config/billability.yml", 'w' ) do |out|
      YAML.dump( billability, out )
    end
  end
end

