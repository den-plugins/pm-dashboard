class MenuMilestonePlansController < PmController

  menu_item :milestones

	before_filter :get_project, :only => [:index, :add, :update, :destroy]
  before_filter :get_version, :only => [:update, :destroy]
  before_filter :authorize
  before_filter :role_check_client

  def index
    @version = Version.find(params[:version_id]) if params[:version_id]
    @version.update_attributes(:state => params[:state]) if @version
    @versions = Version.find(:all, :conditions => ["project_id = ?", @project], :order => 'effective_date IS NULL, effective_date DESC')
  end

  def add
  	if request.get?
  		@version = Version.new
  		render_menu_milestone_plans('add')
  	else
  		@version = Version.new(params[:version])
      @version.project_id = @project.id

      accepted_iteration = true
      if (@version.version_type = 1 && @version.started_date.nil?) || (@version.version_type = 1 && @version.effective_date.nil?)
        accepted_iteration = false
      end

      if !@version.original_start_date.nil? && !@version.original_end_date.nil? && accepted_iteration  && @version.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_menu_milestone_plans
      else
        @version.errors.add_to_base "Please input Original Start Date." if @version.original_start_date.nil?
        @version.errors.add_to_base "Please input Original End Date." if @version.original_end_date.nil?
        @version.errors.add_to_base "Please input Actual Start Date." if @version.version_type = 1 && @version.started_date.nil?
        @version.errors.add_to_base "Please input Latest Re-plan Date." if @version.version_type = 1 && @version.effective_date.nil?
        render_menu_milestone_plans('add')
      end
		end
  end

  def update
  	@version = Version.find(params[:version_id])
    version = params[:version]
    if request.xhr?
      render :partial => "menu_milestone_plans/edit"
    else
      if !version[:original_start_date].nil? && !version[:original_end_date].nil? && !version[:original_start_date].blank? &&
         !version[:original_end_date].blank? && @version.update_attributes(params[:version])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_menu_milestone_plans
      else
        @version.errors.add_to_base "Original Start Date is required." if version[:original_start_date].nil? || version[:original_start_date].blank?
        @version.errors.add_to_base "Original End Date is required." if version[:original_end_date].nil? || version[:original_end_date].blank?
        render :template => "menu_milestone_plans/edit_with_error"
      end
    end
  end

  def destroy
  	@version = Version.find(params[:version_id])

    begin
      @version.destroy
    rescue RuntimeError
      flash[:error] = "Can't delete version"
      redirect_to_menu_milestone_plans
    else
      flash[:notice] = l(:notice_successful_delete)
      redirect_to_menu_milestone_plans
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

	def redirect_to_menu_milestone_plans
		redirect_to :controller => 'menu_milestone_plans', :project_id => @project
	end

	def render_menu_milestone_plans(target)
		render :template => "menu_milestone_plans/#{target}"
	end
end
    
