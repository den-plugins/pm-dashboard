class PmDashboardIssuesController < PmController
  menu_item :project_issues

  before_filter :require_login
  before_filter :get_project, :only => [:index, :show, :add, :edit, :delete]
  before_filter :get_issue, :only => [:index, :show, :edit, :delete]
  before_filter :authorize
  before_filter :role_check_client

  def index
    @project ||= @issue.project
    if params[:id]
      @issues = (@client && @issue.env.eql?('E')) ? [] : [@issue]
    else
      condition = @client ? "env='E'" : ""
      @issues = @project.pm_dashboard_issues.find(:all, :conditions => condition, :order => 'ref_number DESC')
    end
  end
  
  def show
    @project ||= @issue.project
    @issues = (@client && !@issue.env.eql?('E')) ? [] : [@issue]
    p @issues
    render :template => 'pm_dashboard_issues/index'
  end
  
  def add
    if request.get?
      @issue = PmDashboardIssue.new
      render :template => "pm_dashboard_issues/add"
    else
      @issue = @project.pm_dashboard_issues.create(params[:issue])
      if @issue.save
        redirect_to_project_issues
      else
        render :template => "pm_dashboard_issues/add"
      end
    end
  end

  def edit
    if request.get?
      render :template => "pm_dashboard_issues/edit"
    else
      if @issue.update_attributes(params[:issue])
        redirect_to_project_issues
      else
        render :template => "pm_dashboard_issues/edit"
      end
    end
  end

  def delete
    if @issue.destroy
      redirect_to_project_issues
    end
  end

  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    @project.update_days_overdue if @project
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def get_issue
    @issue = PmDashboardIssue.find(params[:id]) if params[:id]
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def redirect_to_project_issues
    redirect_to :controller => 'pm_dashboard_issues', :action => 'index', :project_id => @project
  end
  
  def role_check
    member = @project.members.find(:first, :conditions => ["user_id=?", User.current.id])
    @client = member if !User.current.admin? and (role=member.role) and role.name.downcase.include?('clients')
  end
end
