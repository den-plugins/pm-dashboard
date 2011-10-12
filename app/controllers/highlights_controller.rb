class HighlightsController < ApplicationController

  before_filter :get_project, :get_highlight
  
  def save
    if @highlight.update_attributes(params[:highlight])
      replace_highlights
    else
      render_error_messages
    end
  end
  
  def post
    attrs = {:posted_date => Date.today}
    if @highlight.update_attributes(params[:highlight].merge(attrs))
      replace_highlights
    else
      render_error_messages
    end
  end
  
  def unpost
    attrs = @highlight.attributes.merge({:posted_date => nil})
    if @highlight.update_attributes(attrs)
      replace_highlights
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
  
  def replace_highlights
    @highlights = @project.weekly_highlights
    render :update do |page|
      page.replace_html :recently_posted, :partial => "pm_dashboards/highlights/recently_posted"
      page.replace_html :this_period, :partial => "pm_dashboards/highlights/current"
      page.replace_html :next_period, :partial => "pm_dashboards/highlights/nextp"
    end
  end
  
  def render_error_messages
    @highlight_errors = @highlight.errors.full_messages
    puts @highlight_errors
    render :update do |page|
      page.replace :error_messages, :partial => "pm_dashboards/highlights/errors"
    end
  end
end
