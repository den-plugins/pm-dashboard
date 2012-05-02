module EfficiencyHelper
  OPEN_STATUS = IssueStatus.all(:conditions => ['is_closed = ? AND name NOT IN (?)', false, ['Resolved', 'Verified by QA']]).map(&:id).freeze
  RESOLVED_STATUS = IssueStatus.all(:conditions => ['name IN (?)', ['Resolved', 'Verified by QA']]).map(&:id).freeze
  NOT_DEFECT_STATUS = IssueStatus.all(:conditions => ['name IN (?)', ['Not a Defect', 'Cannot Reproduce']]).map(&:id).freeze
  CLOSED_STATUS = IssueStatus.all(:conditions => ['is_closed = ? AND name NOT IN (?)', true, ['Not a Defect', 'Cannot Reproduce']]).map(&:id).freeze

  def bug_count(status=nil, version=nil)
    conditions = { :project_id => @project.id, :tracker_id => 1 }
    status_id = case status
                when :open        then OPEN_STATUS
                when :not_defect  then NOT_DEFECT_STATUS
                when :resolved    then RESOLVED_STATUS
                when :closed      then [CLOSED_STATUS, NOT_DEFECT_STATUS].flatten
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
