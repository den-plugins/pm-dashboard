class TimeLoggingController < ApplicationController
  menu_item :time_logging

  before_filter :get_project
  before_filter :authorize

  def index
  end

  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
