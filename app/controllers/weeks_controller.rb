class WeeksController < ApplicationController

  helper :pm_dashboards
  before_filter :get_project, :only => [:new, :edit]

  def new
    @week = @project.weeks.build(params[:week])
    @week.inclosed_week = params[:inclosed_week].to_i
    if not @week.save
      err_msg = []
      @week.errors.each { |attr, message| err_msg << "#{message}" }
      flash[:error] = err_msg.join("<br />")
    end
    redirect_to_resource_costs
  end

  def edit
    @week = Week.find(params[:id])
    @week.inclosed_week = params[:inclosed_week].to_i
    if not @week.update_attributes(params[:week])
       err_msg = []
       @week.errors.each { |attr, message| err_msg << "#{message}" }
       flash[:error] = err_msg.join("<br />")
    end
    redirect_to_resource_costs
  end

private
  def get_project
    @project = Project.find(params[:project_id])
  end
  
  def redirect_to_resource_costs
    redirect_to :controller => 'pm_dashboards', :action => 'index', :tab => 'resource_costs', :project_id => @project
  end

end
