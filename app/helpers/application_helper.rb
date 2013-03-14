module ApplicationHelper
  
  def render_main_menu_for_client(project)
    if project
      member = project.members.find(:first, :conditions => ["user_id=?", User.current.id])
      client = member if member and !User.current.admin? and (role=member.role) and role.name.downcase.include?('clients')
    end
    if client
      render_main_menu(project) +
      javascript_tag("(document.getElementsByClassName('pm-dashboards')[0].innerHTML = '#{l(:menu_pm_client_dashboard)}');")
    else
      render_main_menu project
    end
  end

  def log_time_admin(user,proj)
    if user.time_logs_admin?
      calendar_for('lock_tl_date')
    else
      date_calendar_for('lock_tl_date',proj)
    end
  end

  def calendar_for(field_id)
    include_calendar_headers_tags
    date_close = (field_id == "issue_date_close" ? ",dateStatusFunc : futureDate" : "")
    image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y-%m-%d', button : '#{field_id}_trigger' #{date_close} })")
  end

  def date_calendar_for(field_id, obj)
    include_calendar_headers_tags

    lt = case obj.class.to_s
    when "Issue" && obj.project.lock_time_logging then obj.project.lock_time_logging - 1
    when "Project" && obj.lock_time_logging then obj.lock_time_logging - 1
    else nil
    end

    lock_time_logging = (lt.blank? ? "" : ",dateStatusFunc : 
        function(date){ 
          if (date > new Date('#{lt}')){
            return false;
          } else {
            return true;
          }
        }") unless lt.blank?

    image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y-%m-%d', button : '#{field_id}_trigger' #{lock_time_logging} })")
  end


end
