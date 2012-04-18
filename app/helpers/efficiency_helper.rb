module EfficiencyHelper
  OPEN_STATUS = IssueStatus.all(:conditions => ['is_closed = ? AND name NOT IN (?)', false, ['Resolved', 'Verified by QA']])
  RESOLVED_STATUS = IssueStatus.all(:conditions => ['name IN (?)', ['Resolved', 'Verified by QA']])
  CLOSED_STATUS = IssueStatus.all(:conditions => { :is_closed => true }).map(&:id)

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
    raised = []
    closed = []
    weeks.each do |week|
      weekly_raised = Issue.count(:conditions => ['project_id = ? AND tracker_id = ? AND created_on <= ?', @project.id, 1, week.last])
      weekly_closed = Issue.count(:conditions => ['project_id = ? AND tracker_id = ?
                                                  AND journal_details.prop_key = ?
                                                  AND journal_details.value IN (?)
                                                  AND journals.created_on <= ?',
                                                  @project.id, 1, 'status_id', CLOSED_STATUS.map(&:to_s), week.last],
                                  :include => { :journals => :details })
      if weekly_raised > 0 && weekly_closed > 0
        raised << [week.last, weekly_raised.to_i]
        closed << [week.last, weekly_closed.to_i]
      end
    end
    [raised, closed]
  end

  def bug_count(status=nil, version=nil)
    conditions = { :project_id => @project.id, :tracker_id => 1 }
    status_id = case status
                when :open     then OPEN_STATUS
                when :resolved then RESOLVED_STATUS
                when :closed   then CLOSED_STATUS
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
    (bug_count(:closed) / bug_count.to_f).to_f
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
