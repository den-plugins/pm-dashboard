class HighlightsController < ApplicationController

  before_filter :get_project, :get_highlight
  
  def save
    if params[:cancel]
      @highlights = @project.weekly_highlights
      render :update do |page|
        page.replace_html :next_period, :partial => "pm_dashboards/highlights/nextp", :locals => {:highlight => @highlights[:after_current]}
        page.replace_html :this_period, :partial => "pm_dashboards/highlights/current", :locals => {:highlight => @highlights[:current]}
      end
    else
	  update_highlight
      @highlight.update_attributes(params[:highlight]) ? replace_highlights  : render_error_messages
    end
  end
  
  def update_highlight
	date = params[:highlight][:created_at]
	get_highlight = Highlight.find(:all, :conditions => ["created_at = ? and project_id = ?", @highlight.created_at, @project.id])
	get_highlight.each do |h|
		h.update_attributes :created_at => date
	end
  end

  def post
    attrs = {:posted_date => Date.today}
    @highlight.update_attributes(params[:highlight].merge(attrs)) ? replace_highlights : render_error_messages
  end
  
  def unpost
    attrs = @highlight.attributes.merge({:posted_date => nil})
    @highlight.update_attributes(attrs) ? replace_highlights : render_error_messages
  end
  
  def select_by_week
    date = params[:select_week].to_date
    highlight = @project.highlights.for_the_week(date).post_current.first
    render :update do |page|
      page.replace_html :recently_posted, :partial => "pm_dashboards/highlights/recently_posted", :locals => {:highlight => highlight}
    end
  end
  
  def select_duplicate
    date = params[:highlight][:created_at].to_date
    dup = @project.highlights.for_the_week(date).first
    time_state = (params[:time_state].eql?('current') || params[:time_state].eql?('nextp')) ? params[:time_state] : (dup.is_for_next_period ? 'current' : 'nextp')
    period = time_state.eql?('current') ? "this_period" : "next_period"
    
    @highlight.attributes = params[:highlight]
    @highlight.validate

    if @highlight.errors.empty?
      if dup && (dup.posted_date.nil? || (dup.posted_date && in_period(dup)))
		if session[:newhighlight]
        	render :update do |page|
          		page.replace_html period, :partial => "pm_dashboards/highlights/#{time_state}", :locals => {:highlight => dup}
         	 	page.hide "#{time_state}_highlight_wrapper"
        	 	page.show "#{time_state}_highlights_container"
       		 end
		end
		session[:newhighlight] = nil
      else
        @highlight = Highlight.new({:created_at => date})
		session[:newhighlight] = "new"
        render :update do |page|
          page.replace_html period, :partial => "pm_dashboards/highlights/#{time_state}", :locals => {:highlight => @highlight}
          page.hide "#{time_state}_highlight_wrapper"
          page.show "#{time_state}_highlights_container"
        end
      end
    else
      render_error_messages
    end
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_highlight
    @highlight = params[:id] ? @project.highlights.find(params[:id]) : @project.highlights.new
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def in_period(dup)
    if dup.is_for_next_period
      dup.created_at.to_date.monday.eql? (Date.today.monday + 1.week)
    else
      dup.created_at.to_date.monday.eql? Date.today.monday
    end
  end
  
  def render_error_messages
    @highlight_errors = @highlight.errors.full_messages
    render :update do |page|
      if @highlight.is_for_next_period
        page.replace_html :nextp_error_messages, :partial => "pm_dashboards/highlights/errors"
      else
        page.replace_html :current_error_messages, :partial => "pm_dashboards/highlights/errors"
      end
      page["errorExplanation"].show
    end
  end
  
  def replace_highlights
    @highlights = @project.weekly_highlights
    render :update do |page|
      page.replace_html :highlights_summary, :partial => "pm_dashboards/highlights/dashboard"
      page.replace_html :recently_posted, :partial => "pm_dashboards/highlights/recently_posted", :locals => {:highlight => @highlights[:recently_posted]}
      page.replace_html :next_period, :partial => "pm_dashboards/highlights/nextp", :locals => {:highlight => @highlights[:after_current]}
      page.replace_html :this_period, :partial => "pm_dashboards/highlights/current", :locals => {:highlight => @highlights[:current]}
    end
  end
end
