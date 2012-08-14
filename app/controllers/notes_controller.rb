class NotesController < PmController
 
  menu_item :notes

  before_filter :get_project
  before_filter :authorize
  before_filter :role_check_client
  
  include NotesHelper

  def index
    @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
    @versions = @project.versions.sort.collect {|v| [v.name, v.id] }
    @version_list = @project.versions.sort
  end
  
  def create
    project = Project.find params[:project_id]
    @type = params[:type]
    case @type
      when 'project'
        project.notes.create :text => params[:text], :note_type => @type
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        project.notes.create :text => params[:text], :note_type => @type, :version_id => params[:iter_id]
        @versions = project.versions.sort.collect {|v| [v.name, v.id] }
        @version_list = project.versions.sort
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @type = params[:type]
    @versions = @project.versions.sort.collect {|v| [v.name, v.id] } if @type == "iteration"
    @note = Note.find params[:id]
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def update
    project = Project.find params[:project_id]
    @type = params[:type]
    note = Note.find params[:id]
    case @type
      when 'project'
        note.update_attributes :text => params[:text]
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        note.update_attributes :text => params[:text], :version_id => params[:iter_id]
        @versions = project.versions.sort.collect {|v| [v.name, v.id] }
        @version_list = project.versions.sort
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def destroy
    project = Project.find params[:project_id]
    Note.destroy params[:id]
    @type = params[:type]
    case @type
      when 'project'
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        @versions = project.versions.sort.collect {|v| [v.name, v.id] }
        @version_list = project.versions.sort
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
