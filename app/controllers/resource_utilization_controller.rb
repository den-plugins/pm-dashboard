class ResourceUtilizationController < ApplicationController
  menu_item :utilization

  before_filter :require_login
  before_filter :get_project
  before_filter :authorize

  def index
    retrieve_date_range
    @resources = @project.members.project_team
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
  
  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    @project.update_days_overdue if @project
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def retrieve_date_range
    @free_period = false
    @from, @to = nil, nil
    if params[:period_type] == '1' || (params[:period_type].nil? && !params[:period].nil?)
      case params[:period].to_s
      when 'current_week'
        @from = Date.today - (Date.today.cwday - 1)%7
        @to = @from + 6
      when 'last_week'
        @from = Date.today - 7 - (Date.today.cwday - 1)%7
        @to = @from + 6
      when 'current_month'
         current_month
      #when 'last_month'
        #@from = Date.civil(Date.today.year, Date.today.month, 1) << 1
        #@to = (@from >> 1) - 1
      end
    elsif params[:period_type] == '2' || (params[:period_type].nil? && (!params[:from].nil? || !params[:to].nil?))
      begin; @from = params[:from].to_s.to_date unless params[:from].blank?; rescue; end
      begin; @to = params[:to].to_s.to_date unless params[:to].blank?; rescue; end
      @free_period = true
    else
      current_month
    end
    
    @from, @to = @to, @from if @from && @to && @from > @to
    @from ||= (TimeEntry.minimum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today) - 1
    @to   ||= (TimeEntry.maximum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today)
  end
  
  def current_month
    @from = Date.civil(Date.today.year, Date.today.month, 1)
    @to = (@from >> 1) - 1
  end
end
