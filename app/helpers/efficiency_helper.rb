module EfficiencyHelper
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
                   from.weeks_ago(to).eql?(0) ? to : (mon.monday+4.days)
                 end 
        from = mon.next_week
        weeks << (mon .. fri)
      end 
      weeks
    end 
  end

  def chart_data
    weeks = get_weeks_range((Date.today - 6.months).monday, (Date.today - 1.week).end_of_week - 2.days)
    start_date = @project.actual_start_date || @project.planned_start_date || weeks.first.first
    raised = []
    closed = []
    weeks.each do |week|
      weekly_raised = Issue.count(:conditions => ['project_id = ? AND tracker_id = ? AND created_on BETWEEN ? AND ?', @project.id, 1, start_date, week.last])
      weekly_closed = Issue.count(:conditions => ['project_id = ? AND tracker_id = ? AND status_id = ? AND created_on BETWEEN ? AND ?', @project.id, 1, IssueStatus.find_by_name('Closed').id, start_date, week.last]) # TODO for confirmation
      raised << [week.last, weekly_raised.to_i]
      closed << [week.last, weekly_closed.to_i]
    end
    [raised, closed]
  end

  def bug_count(status=nil, version=nil)
    conditions = { :project_id => @project.id, :tracker_id => 1 }
    status_id = case status
                when :open then IssueStatus.find_by_name('Open')
                when :resolved then IssueStatus.find_by_name('Resolved')
                when :closed then IssueStatus.find_by_name('Closed')
                end
    version_id = version.id unless version.blank?
    conditions.merge!(:status_id => status_id) unless status_id.blank?
    conditions.merge!(:fixed_version_id => version_id) unless version_id.blank?
    Issue.count(:conditions => conditions)
  end

  def test_code_coverage
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Test Code Coverage' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def defect_ratio
    bug_count(:closed) / bug_count.to_f
  end

  def status
    # TODO for confirmation
    0.5 * test_code_coverage + 0.5 * (100.0 * defect_ratio)
  end

  def status_color
    if status > 80
      'green'
    elsif status > 70
      'yellow'
    else
      'red'
    end
  end
end
