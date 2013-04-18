class EfficiencyController < PmController
  before_filter :get_project, :only => [:index, :update_test_code_coverage, :update_unit_testing_weight, :update_unit_testing_score,
                                        :update_automation_testing_weight, :update_automation_testing_score, :update_defect_removal_weight,
                                        :update_total_closed_defects, :update_total_raised_defects, :load_chart]
  before_filter :authorize
  before_filter :role_check_client

  caches_action :load_chart, :layout => false

  include EfficiencyHelper

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date DESC').reverse
  end

  def update_unit_testing_weight
    if coverage_field = ProjectCustomField.find_by_name('Unit Testing Weight')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Unit Testing Weight' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_unit_testing_score
    if coverage_field = ProjectCustomField.find_by_name('Unit Testing Score')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Unit Testing Score' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_automation_testing_weight
    if coverage_field = ProjectCustomField.find_by_name('Automation Testing Weight')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Automation Testing Weight' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_automation_testing_score
    if coverage_field = ProjectCustomField.find_by_name('Automation Testing Score')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Automation Testing Score' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_defect_removal_weight
    if coverage_field = ProjectCustomField.find_by_name('Defect Removal Weight')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Defect Removal Weight' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_total_closed_defects
    if coverage_field = ProjectCustomField.find_by_name('Total Closed Defects')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Total Closed Defects' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def update_total_raised_defects
    if coverage_field = ProjectCustomField.find_by_name('Total Raised Defects')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Total Raised Defects' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
    end
    head :ok
  end

  def load_chart
    respond_to do |format|
      format.json do
        render :json => chart_data
      end
    end
  end

  def chart_data
    weeks = get_full_weeks_range((Date.today - 6.months), Date.today)
    closed_statuses = [NOT_DEFECT_STATUS, CLOSED_STATUS].flatten.map{|v| %{'#{v}'}}.join(',')
    raised = []
    closed = []

    weeks.each do |week|
      journals_join = "INNER JOIN (SELECT journals.journalized_id, MAX(journals.created_on) AS created_on
                         FROM journals
                           LEFT OUTER JOIN journal_details ON journal_details.journal_id = journals.id
                           WHERE journals.journalized_type = 'Issue'
                             AND journal_details.prop_key = 'status_id'
                             AND journal_details.value IN (#{closed_statuses})
                             AND journals.created_on <= '#{week.last}'
                           GROUP BY journals.journalized_id) details ON details.journalized_id = issues.id".squeeze(' ')

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

private
  def get_project
    @dev_project = @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

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
end
