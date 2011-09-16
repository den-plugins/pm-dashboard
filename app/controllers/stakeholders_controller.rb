class StakeholdersController < ApplicationController

  before_filter :get_project

  def new
    @stakeholder = Stakeholder.new
    render :partial => "pm_dashboards/project_info/new_stakeholder"
  end

  def create
    begin
      @stakeholder = @project.stakeholders.create(params[:stakeholder])
    rescue
      flash[:error] = "Missing required fields in creating stakeholder. Record not saved."
      redirect_to :controller => 'pm_dashboards', :action => 'index', :project_id => @project, :tab => :info
    else
      flash[:notice] = "Successful creation of Stakeholder."
      redirect_to :controller => 'pm_dashboards', :action => 'index', :project_id => @project, :tab => :info
    end
  end

  def edit
    @positions = PmPosition.find(:all) #Positions created by PM
    @roles = PmRole.find(:all, :conditions => "for_stakeholder = TRUE") #Roles created by PM
    @stakeholder = @project.stakeholders.find(params[:id])
    render :partial => "pm_dashboards/project_info/stakeholder_edit", :locals => {:member => @stakeholder}
  end

  def update
    @member = Stakeholder.find(params[:id]) 

    if @member.update_attributes(params[:member])
      render(:update) {|page| page.replace_html "tr_stakeholder_#{@member.id}", 
      {:partial => "pm_dashboards/project_info/stakeholder_edit", 
       :locals => {:member => @member}}}
    end
  end

  def remove
    @stakeholder = Stakeholder.find(params[:id])
    @project.stakeholders.delete(@stakeholder)
    redirect_to :controller => 'pm_dashboards', :project_id => @project, :tab => :info
  end

private
  def get_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
end
