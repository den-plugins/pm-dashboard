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

  def unit_testing_weight
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Unit Testing Weight' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def unit_testing_score
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Unit Testing Score' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def automation_testing_weight
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Automation Testing Weight' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def automation_testing_score
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Automation Testing Score' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def defect_removal_weight
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Defect Removal Weight' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def total_closed_defects
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Total Closed Defects' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def total_raised_defects
    coverage_field = @project.custom_values.detect { |v| v.custom_field.name == 'Total Raised Defects' }
    coverage_field ? coverage_field.value.to_f : 0.0
  end

  def defect_ratio
    ((bug_count(:closed) / bug_count.to_f) * 100).to_f
  end

  def defect_removal_score
    ratio = total_raised_defects > 0 ? ((total_closed_defects/total_raised_defects) * 100).to_f : 0.00
  end

  def status
    unit_testing_weighted_score + automation_testing_weighted_score + defect_removal_weighted_score
  end

  def unit_testing_weighted_score
    unit_testing_weight * unit_testing_score
  end

  def automation_testing_weighted_score
    automation_testing_weight * automation_testing_score
  end

  def defect_removal_weighted_score
    if @project.for_time_logging_only?
      defect_removal_weight * defect_removal_score
    else
      defect_removal_weight * defect_ratio
    end
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
