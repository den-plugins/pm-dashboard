class NotesController < PmController
 
  menu_item :notes

  before_filter :get_project
  before_filter :authorize
  before_filter :role_check_client
  
  include NotesHelper

  def index
    @versions = @project.versions.sort.collect {|v| [v.name, v.id] }
    @version_list = @project.versions.sort.reverse
    @proj_notes = @project.notes.sort_by {|z| z.updated_at}.reverse
  end
  
  def create
    project = Project.find params[:project_id]
    case params[:type]
      when 'project'
        @type = "project"
        project.notes.create :text => params[:text], :type => @type
        @proj_notes = project.notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        @type = "iteration"
        version = Version.find(params[:iter_id])
        version.notes.create :text => params[:text], :type => @type, :project_id => project.id
        @version_list = project.versions.sort.reverse
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
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
