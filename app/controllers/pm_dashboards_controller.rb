class PmDashboardsController < ApplicationController

  def index
    @project = Project.find(params[:project_id])
    @assumptions = @project.assumptions.all
  end
end
