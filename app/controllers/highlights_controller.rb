class HighlightsController < ApplicationController

  before_filter :get_project, :get_highlights
  
  def new
    @highlight = @project.highlights.build(params[:highlight])
    if @highlight.save
      render :update do |page|
        page.replace_html :highlights_container, :partial => 'pm_dashboards/highlights/list'
        page.hide :new_highlight
        page.show :highlights_container
      end
    else
      render :update do |page|
        page.replace :new_highlight, :partial => 'pm_dashboards/highlights/form'
        page.show :new_highlight
      end
    end
  end
  
  def update
    @highlight = Highlight.find(params[:id])
    @highlight.update_attributes(params[:highlight])
    render :update do |page|
      page.replace_html :highlights_container, :partial => 'pm_dashboards/highlights/list'
    end
  end
  
  
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def get_highlights
    @highlights = @project.highlights.this_week
  end
end
