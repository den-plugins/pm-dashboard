module ProjectBillabilityHelper

  def compute_labor_hours(week, resources)
    allocated = resources.select {|r| r.billable?(week.first, week.last) }
    week.count * 8 * allocated.count
  end
end
