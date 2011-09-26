class MilestonePlansController < ApplicationController

  helper :assumptions
  helper :risks
  helper :project_info
  helper :pm_dashboard_issues
  helper :resource_costs
	helper :pm_dashboards
	helper :scrums

	before_filter :get_project, :only => [:add, :update, :destroy]
  before_filter :get_version, :only => [ :update, :destroy]

  def index

  end

  def add
  	if request.get?
  		@version = Version.new
  		render_milestone_plans('add')
  	else
  		@version = Version.new(params[:version])
      @version.project_id = @project.id

      if @version.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_milestone_plans
      else
        render_milestone_plans('add')
      end
		end
  end

  def update
  	@version = Version.find(params[:version_id])

    if request.xhr?
      render :partial => "pm_dashboards/milestone_plans/edit"
    else
      if @version.update_attributes(params[:version])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_milestone_plans
      else
        render_milestone_plans('_edit')
      end
    end
  end

  def destroy
  	@version = Version.find(params[:version_id])
    if @version.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to_milestone_plans
    end
  end

private

	def get_project
		@project = Project.find(params[:project_id])
		rescue ActiveRecord::RecordNotFound
			render 404
	end

	def get_version
		@version = Version.find(params[:version_id])
		rescue ActiveRecord::RecordNotFound
			render 404
	end	

	def redirect_to_milestone_plans
		redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :milestone_plans
	end

	def render_milestone_plans(target)
		render :template => "pm_dashboards/milestone_plans/#{target}"
	end
end
    