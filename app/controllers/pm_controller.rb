class PmController < ApplicationController
  helper :pm_dashboards
   
  def role_check
    member = @project.members.find(:first, :conditions => ["user_id=?", User.current.id])
    @client = member if !User.current.admin? and (role=member.role) and role.name.downcase.include?('clients')
    deny_access if @client
  end

  def role_check_client
    member = @project.members.find(:first, :conditions => ["user_id=?", User.current.id])
    @client = member if !User.current.admin? and (role=member.role) and role.name.downcase.include?('clients')
  end
end
