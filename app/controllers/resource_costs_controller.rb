class ResourceCostsController < PmController
  menu_item :forecasts
  include FaceboxRender
    
  before_filter :get_project
  before_filter :authorize, :only => [:index, :edit_project]
  before_filter :role_check, :only => [:index, :edit_project]

  def index
    @proj_team = @project.members.project_team
    update_resource_list
  end
  
  def edit_project
    if request.post?
      @project.attributes = params[:project]
      @proj_team = @project.members.project_team
      if @project.save
        render :update do |page|
          page.redirect_to :action => :index, :project_id => @project
        end
      else
        render :update do |page|
          page.replace_html :resource_costs_header , :partial => 'resource_costs/header'
        end
      end
    end
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def update_resource_list
    if params[:view] or params[:rate]
      render(:update) do |p| 
        p.replace_html "resource_members_content", :partial => 'resource_costs/list' 
      end
    end
  end
end
