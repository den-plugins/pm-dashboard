class ProjectInfoController < ApplicationController
  
  before_filter :require_login
  before_filter :get_project, :only => [:add, :update, :destroy]

  def add

  end

  def update

  end

  def destroy

  end


private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
