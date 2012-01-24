class CostMonitoringController < ApplicationController

  menu_item :bottomline
  before_filter :get_project
  before_filter :authorize, :only => [:index]

  def index
    
  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
