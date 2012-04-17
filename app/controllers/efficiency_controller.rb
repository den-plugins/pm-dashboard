class EfficiencyController < PmController
  before_filter :get_project, :only => [:index, :add, :update, :destroy]
  before_filter :authorize
  before_filter :role_check_client

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date ASC')
  end

private
  def get_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
