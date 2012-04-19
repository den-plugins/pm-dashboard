module EfficiencyHelper
  OPEN_STATUS = IssueStatus.all(:conditions => ['is_closed = ? AND name NOT IN (?)', false, ['Resolved', 'Verified by QA']]).map(&:id).freeze
  RESOLVED_STATUS = IssueStatus.all(:conditions => ['name IN (?)', ['Resolved', 'Verified by QA']]).map(&:id).freeze
  NOT_DEFECT_STATUS = IssueStatus.all(:conditions => ['name IN (?)', ['Not a Defect', 'Cannot Reproduce']]).map(&:id).freeze
  CLOSED_STATUS = IssueStatus.all(:conditions => ['is_closed = ? AND name NOT IN (?)', true, ['Not a Defect', 'Cannot Reproduce']]).map(&:id).freeze

  def get_full_weeks_range(from, to) 
    if from && to
      start_date, end_date = from, to
      weeks = []
      until ((from..to).to_a & (start_date..end_date).to_a).empty?
        mon = from.monday
        sun = mon.end_of_week

        from = mon.next_week
        weeks << (mon .. sun)
      end 
      weeks
    end 
  end

  def chart_data
    weeks = get_full_weeks_range((Date.today - 6.months), Date.today)
    journals_join = "INNER JOIN (
                       SELECT journals.journalized_id, MAX(journals.created_on) AS created_on
                       FROM journals
                         LEFT OUTER JOIN journal_details ON journal_details.journal_id = journals.id
                         WHERE journals.journalized_type = 'Issue'
                           AND journal_details.prop_key = 'status_id'
                           AND journal_details.value IN (#{[NOT_DEFECT_STATUS, CLOSED_STATUS].flatten.map{|v| %{'#{v}'}}.join(',')})
                         GROUP BY journals.journalized_id
                     ) details ON details.journalized_id = issues.id".squeeze(' ')
    raised = []
    closed = []

    weeks.each do |week|
      weekly_raised = Issue.count(:conditions => ['project_id = ? AND tracker_id = ? AND created_on <= ?',
                                                   @project.id, 1, week.last])
      weekly_closed = Issue.count(:joins => journals_join,
                                   :conditions => ['project_id = ? AND tracker_id = ? AND details.created_on <= ?',
                                                   @project.id, 1, week.last])
      if weekly_raised > 0 || weekly_closed > 0
        raised << [week.last, weekly_raised]
        closed << [week.last, weekly_closed]
      end
    end

    [raised, closed]
  end

  def bug_count(status=nil, version=nil)
    conditions = { :project_id => @project.id, :tracker_id => 1 }
    status_id = case status
                when :open        then OPEN_STATUS
                when :not_defect  then NOT_DEFECT_STATUS
                when :resolved    then RESOLVED_STATUS
                when :closed      then CLOSED_STATUS
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
