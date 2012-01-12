class HighlightsController < ApplicationController

  menu_item :highlights

  before_filter :get_project, :get_highlight
  before_filter :authorize
  
  include HighlightsHelper
  
  def index
    @highlights = @project.weekly_highlights
    if params[:edit_what] == 'current'
      @jscmd = "jQuery('#current').trigger('click'); jQuery('#highlights_edit').trigger('click')"
    elsif params[:edit_what] == 'nextp'
      @jscmd = "jQuery('#nextp').trigger('click'); jQuery('#highlights_edit').trigger('click');"
    elsif params[:edit_what] == 'recently_posted'
      @jscmd = "$('recently_posted').highlight({startColor : '#FF9999'});"
    end
  end
  
  def save
    if params[:cancel]
      @highlights = @project.weekly_highlights
      render :update do |page|
        page.replace_html :next_period, :partial => "highlights/nextp", :locals => {:highlight => @highlights[:after_current]}
        page.replace_html :this_period, :partial => "highlights/current", :locals => {:highlight => @highlights[:current]}
      end
    else
	    #update_highlight
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
    highlight_next = @project.highlights.for_the_week(date).post_after_current.first
    render :update do |page|
      page.replace_html :recently_posted, :partial => "highlights/recently_posted", :locals => {:highlight => highlight, :highlight_next => highlight_next}
    end
  end
  
  def select_duplicate
    date = params[:highlight][:created_at].to_date
    current_dup = @project.highlights.for_the_week(date).detect {|d| !d.is_for_next_period}
    nextp_dup = @project.highlights.for_the_week(date).detect {|d| d.is_for_next_period}
    
    current_highlight = @project.highlights.new params[:highlight].merge({'is_for_next_period' => 'false', 'highlight' => ""})
    current_highlight.validate
    nextp_highlight = @project.highlights.new params[:highlight].merge({'is_for_next_period' => 'true', 'highlight' => ""})
    nextp_highlight.validate
    
    render :update do |page|
      if current_highlight.errors.empty?
        page.replace_html :this_period, :partial => "highlights/current",
                  :locals => {:highlight => (current_dup && (!current_dup.posted? || current_dup.posted_this_week?)) ? current_dup : current_highlight}
      else
        @highlight_errors = current_highlight.errors.full_messages
        page.replace_html :current_error_messages, :partial => "highlights/errors"
      end
      if nextp_highlight.errors.empty?
        page.replace_html :next_period, :partial => "highlights/nextp",
                    :locals => {:highlight => (nextp_dup && (!nextp_dup.posted? || nextp_dup.posted_this_week?)) ? nextp_dup : nextp_highlight}
      else
        @highlight_errors = nextp_highlight.errors.full_messages
        page.replace_html :nextp_error_messages, :partial => "highlights/errors"
      end
      page.hide :current_highlight_wrapper
      page.show :current_highlights_container
      page.hide :nextp_highlight_wrapper
      page.show :nextp_highlights_container
    end
    
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_highlight
    @highlight = (params[:id] and !params[:id].blank?) ? @project.highlights.find(params[:id]) : @project.highlights.new
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def render_error_messages
    @highlight_errors = @highlight.errors.full_messages
    period = @highlight.is_for_next_period ? "nextp" : "current"
    render :update do |page|
      page.replace_html "#{period}_error_messages", :partial => "highlights/errors"
    end
  end
  
  def replace_highlights
    @highlights = @project.weekly_highlights
    render :update do |page|
      page.replace_html :recently_posted, :partial => "highlights/recently_posted", :locals => {:highlight => @highlights[:posted_current], :highlight_next => @highlights[:posted_after_current]}
      page.replace_html :next_period, :partial => "highlights/nextp", :locals => {:highlight => @highlights[:after_current]}
      page.replace_html :this_period, :partial => "highlights/current", :locals => {:highlight => @highlights[:current]}
    end
  end
end
