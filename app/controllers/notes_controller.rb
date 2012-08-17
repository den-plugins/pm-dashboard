class NotesController < PmController
 
  menu_item :notes

  before_filter :get_project
  before_filter :authorize
  before_filter :role_check_client
  
  include NotesHelper

  def index
    @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
    get_versions
    @note = @project.notes.new
  end
  
  def create
    note = params[:note]
    note[:note_type] = note[:type]
    @project.notes.create note
    @note = @project.notes.last
    case @note.note_type
      when 'project'
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        get_versions
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @type = params[:type]
    get_versions
    @note = Note.find params[:id]
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def update
    note = params[:note]
    @note = Note.find(note[:id])
    @note.update_attributes note
    case @note.note_type
      when 'project'
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        get_versions
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def destroy
    @iteration = Note.find(params[:id]).iteration
    Note.destroy params[:id]
    @type = params[:type]
    case @type
      when 'project'
        @proj_notes = @project.project_notes.sort_by {|z| z.updated_at}.reverse
      when 'iteration'
        get_versions
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

  def get_versions
    @version_list = @project.versions.sort
    @versions = @version_list.collect {|v| [v.name, v.id] }
  end
end
