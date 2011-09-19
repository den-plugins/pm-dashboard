class MilestonePlansController < ApplicationController

	before_filter :get_project, :only => [:add, :update, :destroy, :destroy_release, :add_release]
  
  def index

  end

  def add_release
    @release = Release.new(:project_id => @project.id)
    @release.save

    flash[:notice] = l(:notice_successful_create)
    redirect_to_milestone_plans
  end

  def add
  	if request.get?
  		@milestone = Milestone.new
  		render_milestone_plans('add')
  	else
  		@release = Release.find(params[:release_id])
  		@milestone = Milestone.new(params[:milestone])
      @milestone.release_id = @release.id

      if @milestone.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_milestone_plans
      else
        render_milestone_plans('add')
      end
		end
  end

  def update
  	@milestone = Milestone.find(params[:milestone_id])
    if request.get?
      render_milestone_plans('edit')
    else
      if @milestone.update_attributes(params[:milestone])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_milestone_plans
      else
        render_milestone_plans('edit')
      end
    end
  end

  def destroy
  	@milestone = Milestone.find(params[:milestone_id])
    if @milestone.destroy
      redirect_to_milestone_plans
    end
  end

  def destroy_release
  	@release = Release.find(params[:release_id])
    if @release.destroy
      redirect_to_milestone_plans
    end
  end

private

	def get_project
		@project = Project.find(params[:project_id])
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
    