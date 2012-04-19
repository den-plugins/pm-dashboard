class EfficiencyController < PmController
  before_filter :get_project, :only => [:index, :update_test_code_coverage, :load_chart]
  before_filter :authorize
  before_filter :role_check_client

  caches_action :load_chart, :layout => false

  include EfficiencyHelper

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date DESC').reverse
  end

  def update_test_code_coverage
    if coverage_field = ProjectCustomField.find_by_name('Test Code Coverage')
      if coverage_value = @project.custom_values.detect { |v| v.custom_field.name == 'Test Code Coverage' }
        coverage_value.update_attribute :value, params[:coverage].to_f.to_s
      else
        @project.custom_values.build(:custom_field => coverage_field, :value => params[:coverage].to_f.to_s).save
      end
      head :ok
    end
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

private
  def get_project
    @project = Project.find(params[:project_id])
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
