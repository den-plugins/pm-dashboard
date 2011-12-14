class MilestonePlansController < ApplicationController

  menu_item :milestones
  
	before_filter :get_project, :only => [:index, :add, :update, :destroy]
  before_filter :get_version, :only => [:update, :destroy]
  before_filter :authorize

  def index
    @version = Version.find(params[:version_id]) if params[:version_id]
    @version.update_attribute(:state, params[:state]) if @version
    @versions = Version.find(:all, :conditions => ["project_id = ?", @project], :order => 'effective_date IS NULL, effective_date DESC')
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
      render :partial => "milestone_plans/edit"
    else
      if @version.update_attributes(params[:version])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_milestone_plans
      else
        render :template => "milestone_plans/edit_with_error"
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
			render_404
	end

	def get_version
		@version = Version.find(params[:version_id])
		rescue ActiveRecord::RecordNotFound
			render_404
	end

	def redirect_to_milestone_plans
		redirect_to :controller => 'milestone_plans', :project_id => @project
	end

	def render_milestone_plans(target)
		render :template => "milestone_plans/#{target}"
	end
end
    
