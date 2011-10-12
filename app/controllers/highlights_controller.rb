class HighlightsController < ApplicationController

  before_filter :get_project
  
  def new
    @highlight = @project.highlights.build(params[:highlight])
    if @highlight.save
      render :update do |page|
        page.replace :highlights_container, :partial => 'pm_dashboards/highlights/list'
      end
    else
      render :update do |page|
        page.replace :highlight_form, :partial => 'pm_dashboards/highlights/form'
        page.hide :highlights_container
        page.show :highlight_form
      end
    end
  end
  
  def edit
    @highlight = Highlight.find(params[:id])
    if @highlight.update_attributes(params[:highlight])
      render :update do |page|
        page.replace_html :highlights_container, :partial => 'pm_dashboards/highlights/list'
      end
    else
      page.replace :highlight_form, :partial => 'pm_dashboards/highlights/form'
      page.hide :highlights_container
      page.show :highlight_form
    end
  end
  
  
  private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
