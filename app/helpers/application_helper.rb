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
end
