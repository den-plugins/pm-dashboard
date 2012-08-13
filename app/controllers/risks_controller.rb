class RisksController < PmController
  menu_item :risks
  helper :sort
  include SortHelper

  before_filter :require_login
  before_filter :get_project, :only => [:index, :show, :add, :update, :destroy]
  before_filter :get_risk, :only => [:index, :show, :update, :destroy]
  before_filter :authorize
  before_filter :role_check_client

  def index
    sort_init 'ref_number'
    sort_update %w(ref_number key_risk status)

    @project ||= @risk.project
    if params[:id]
      @risks = (@client && @risk.env.eql?('E')) ? [] : [@risk]
    else
      condition = @client ? "env='E'" : ""
      @risks = @project.risks.find(:all, :conditions => condition, :order => sort_clause)
    end
  end
  
  def show
    @project ||= @risk.project
    @risks = (@client && !@risk.env.eql?('E')) ? [] : [@risk]
    render :template => "risks/index"
  end
  
  def add
    if request.get?
      @risk = Risk.new
      render :template => "risks/add" 
    else
      @risk = @project.risks.create(params[:risk])
      if @risk.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to_risks
      else
        render :template => "risks/add"
      end
    end
  end
  
  def update
    if request.get?
      render :template => "risks/edit"
    else
      if @risk.update_attributes(params[:risk])
        flash[:notice] = l(:notice_successful_update)
        redirect_to_risks
      else
        render :template => "risks/edit"
      end
    end
  end
    
  def destroy
    if @risk.destroy
      redirect_to_risks
    end
  end
    
  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    @project.update_days_overdue if @project
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_risk
    @risk = Risk.find(params[:id]) if params[:id]
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_risks
    redirect_to :controller => 'risks', :action => 'index', :project_id => @project
  end
end
