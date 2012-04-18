class EfficiencyController < PmController
  before_filter :get_project, :only => [:index, :update_test_code_coverage]
  before_filter :authorize
  before_filter :role_check_client

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date ASC')
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

private
  def get_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
