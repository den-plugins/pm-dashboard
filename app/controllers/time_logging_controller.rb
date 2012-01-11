class TimeLoggingController < ApplicationController
  menu_item :time_logging
  helper :resource_costs
  helper :sort
  include SortHelper

  before_filter :get_project
  before_filter :authorize

  def index
    sort_init "#{User.table_name}.lastname", "ASC"
     sort_update({"resource" =>  "#{User.table_name}.lastname"})

    @resources = @project.members.project_team.find(:all, :order => sort_clause)
    retrieve_data
    
    render :template => "time_logging/index", :layout => !request.xhr?
  end

  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def retrieve_date_range
    @from, @to = @to, @from if @from && @to && @from > @to
    @from ||= (Date.today.monday - 3.weeks)
    @to ||= (Date.today.monday + 4.days)
  end
  
  def retrieve_data
    retrieve_date_range
    @columns = (params[:columns] && %w(year month week day).include?(params[:columns])) ? params[:columns] : 'week'
    @users = @resources.collect {|m| m.user }
    @projects = @project.closest_admins << @project

    ####################SUMMARY COMPUTATION###################
    user_list = (@users.size > 0)? "time_entries.user_id in (#{@users.collect(&:id).join(',')}) and" : ""
    project_list = (@projects.size > 0)? "time_entries.project_id in (#{@projects.collect(&:id).join(',')}) and" : ""
    
    bounded_time_entries_billable = TimeEntry.find(:all,
                                :conditions => ["#{user_list} #{project_list} spent_on between ? and ? and issues.acctg_type = (select id from enumerations where name = 'Billable')",
                                @from, @to],
                                :include => [:project],
                                :joins => [:issue],
                                :order => "projects.name asc" )
    bounded_time_entries_billable.each{|v| v.billable = true }
    bounded_time_entries_non_billable = TimeEntry.find(:all,
                                :conditions => ["#{user_list} #{project_list} spent_on between ? and ? and issues.acctg_type = (select id from enumerations where name = 'Non-billable')",
                                @from, @to],
                                :include => [:project],
                                :joins => [:issue],
                                :order => "projects.name asc" )
    bounded_time_entries_non_billable.each{|v| v.billable = false }
    time_entries = TimeEntry.find(:all,
                                :conditions => ["#{user_list} spent_on between ? and ?",
                                @from, @to] )
    
    ######################################
    # th = total hours regardless of selected projects
    # tth = total hours on selected projects
    # tbh = total billable hours on selected projects
    # tnbh = total non-billable hours on selected projects
    ######################################

    @th = time_entries.collect(&:hours).compact.sum
    @tbh = bounded_time_entries_billable.collect(&:hours).compact.sum
    @tnbh = bounded_time_entries_non_billable.collect(&:hours).compact.sum
    @thos = (@tbh + @tnbh)
    @summary = []
    
    project_ids = [@project.id]
    @resources.each_with_index do |res, icount|
      if res.class.to_s == "Member"
        usr = res.user
        b = bounded_time_entries_billable.select{|v| v.user_id == usr.id }
        nb = bounded_time_entries_non_billable.select{|v| v.user_id == usr.id }
        x = Hash.new
        
        x[:count] = icount
        x[:location] = usr.location
        x[:name] = "#{usr.lastname}, #{usr.firstname}"
        x[:skill] = usr.skill
        x[:entries] = b + nb
        x[:total_hours] = time_entries.select{|v| v.user_id == usr.id }.collect(&:hours).compact.sum
        x[:billable_hours] = b.collect(&:hours).compact.sum
        x[:non_billable_hours] = nb.collect(&:hours).compact.sum
        x[:forecasted_hours_on_selected] = res.days_and_cost(@from..@to) * 8
        x[:total_hours_on_selected] = x[:billable_hours] + x[:non_billable_hours]
        @summary.push(x)
      end
    end
    @summary = @summary.sort_by {|c| c.count }
  end
end
