class TimeLoggingController < PmController
  menu_item :time_logging
  helper :resource_costs
  helper :sort
  include SortHelper
  
  before_filter :get_project
  before_filter :authorize
  before_filter :role_check

  def index
    sort_init "#{User.table_name}.lastname", "ASC"
    sort_update({"resource" =>  "#{User.table_name}.lastname", "location" => "location"})
    @res = @project.members.project_team.find(:all, :order => sort_clause)
    retrieve_data
    render :template => "time_logging/index", :layout => !request.xhr?
  end

  def settings
    if request.post?
      flash.now[:notice] = "Lock time logging updated"
      if params[:lock_tl] && params[:lock_tl_date]
        @project.update_attribute(:lock_time_logging, params[:lock_tl_date])
        # update corresponding admin lock time log date
        if @project.parent && @project.parent.children
          @project.parent.children.each do |child|
            @child_admin = child if child.is_admin_project?
          end
          if @child_admin
            @child_admin.update_attribute(:lock_time_logging, params[:lock_tl_date])
          end
        end
      else
        @project.update_attribute(:lock_time_logging, nil)
      end
    end
    index
  end

  private
  def get_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def current_month
    @from = Date.civil(Date.today.year, Date.today.month, 1)
    @to = (@from >> 1) - 1
  end
  
  def retrieve_data
    retrieve_date_range
    @resources = @res.select {|v| !v.resource_allocations.find(:all, :conditions => ["start_date < ? AND end_date > ?", @to, @from]).empty?}
    @show_only = (params[:show_only].blank?)? "both" : params[:show_only]
    @columns = (params[:columns] && %w(year month week day).include?(params[:columns])) ? params[:columns] : 'day'
    @users = @resources.collect {|m| m.user }
    # include in list of projects the related 'admin' project(s) for leaves, holidays, etc
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

        max_hours = 0
        admin_log = 0
        (@from..@to).to_a.each do |day|

          holiday = Holiday.find(:first, :conditions => ["event_date = ?", day])
          allocation = res.resource_allocations.find(:first, :include => [:member] ,:conditions => ["members.user_id = ? and members.project_id = ? and (? BETWEEN start_date AND end_date )", res.user.id, res.project_id, day])
          time_entries_for_the_day = TimeEntry.find(:all, :conditions => ["user_id = ? and spent_on = ?", res.user.id, day])

          if time_entries_for_the_day
            time_entries_for_the_day.each do |entry|
              if entry.project.is_admin_project? && !entry.hours.eql?(0.0)
                case allocation.resource_allocation
                when 100
                  admin_log += 8
                when 75
                  admin_log += 6
                when 50
                  admin_log += 4
                when 25
                  admin_log += 2
                end
              end
            end
          end

          if allocation && ![0,6].include?(day.wday) && !(holiday && holiday.holiday_on_member_location?(res.user))
            case allocation.resource_allocation
            when 100
              max_hours += 8
            when 75
              max_hours += 6
            when 50
              max_hours += 4
            when 25
              max_hours += 2
            end
          end
        end

        x[:project_id] = @project.id
        x[:count] = icount
        x[:user_id] = usr.id
        x[:location] = usr.location
        x[:name] = usr.display_name
        x[:role] = res.pmrole
        x[:entries] = b + nb
        x[:total_hours] = time_entries.select{|v| v.user_id == usr.id }.collect(&:hours).compact.sum
        x[:max_hours] = max_hours - admin_log
        x[:billable_hours] = b.collect(&:hours).compact.sum
        x[:non_billable_hours] = nb.collect(&:hours).compact.sum
        x[:forecasted_hours_on_selected] = res.days_and_cost(@from..@to) * 8        # shadow allocations included
        x[:total_hours_on_selected] = x[:billable_hours] + x[:non_billable_hours]
        
        @summary.push(x)
      end
    end
    @summary = @summary.sort_by {|c| c.count }
  end
  
  def retrieve_date_range
    @free_period = false
    @from, @to = nil, nil

    if params[:period_type] == '1' || (params[:period_type].nil? && !params[:period].nil?)
      case params[:period].to_s
      when 'today'
        @from = @to = Date.today
      when 'yesterday'
        @from = @to = Date.today - 1
      when 'current_week'
        @from = Date.today - (Date.today.cwday - 1)%7
        @to = @from + 6
      when 'last_week'
        @from = Date.today - 7 - (Date.today.cwday - 1)%7
        @to = @from + 6
      when '7_days'
        @from = Date.today - 7
        @to = Date.today
      when 'current_month'
         current_month
      when 'last_month'
        @from = Date.civil(Date.today.year, Date.today.month, 1) << 1
        @to = (@from >> 1) - 1
      when '30_days'
        @from = Date.today - 30
        @to = Date.today
      when 'current_year'
        @from = Date.civil(Date.today.year, 1, 1)
        @to = Date.civil(Date.today.year, 12, 31)
      when 'all'
        @from ||= (TimeEntry.minimum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today) - 1
        @to   ||= (TimeEntry.maximum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today)
      end
    elsif params[:period_type] == '2' || (params[:period_type].nil? && (!params[:from].nil? || !params[:to].nil?))
      begin; @from = params[:from].to_s.to_date unless params[:from].blank?; rescue; end
      begin; @to = params[:to].to_s.to_date unless params[:to].blank?; rescue; end
      @free_period = true
    else
      @from = Date.today - 7 - (Date.today.cwday - 1)%7
      @to = @from + 6   #until sunday
    end

    @from, @to = @to, @from if @from && @to && @from > @to
  end
end
