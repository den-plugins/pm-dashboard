module ProjectInfoHelper

  def sorted_members(project)
    project.members.sort_by {|m| m.user.name.strip}
  end

  def custom_field_headers
    str = ""
    if !@user_custom_fields.nil?
      @user_custom_fields.each do |field|
        str += "<th>#{field.name}</th>" if field.editable
      end
    end
    str
  end
  
  def options_for_select_pm_members_collection(classification)
    members = selected_members(classification)
    options = ""
    members.each do |m|
      options += "<option value=#{m.is_a?(Stakeholder) ? (m.id.to_s + "_s") : m.id} "
      options += "#{disable_if_has_logs(m)} " unless classification.eql?(:stakeholder)
      options += ">#{m.name}</option>"
    end
    options
  end
  
  def disable_if_has_logs(member)
    member.time_entries.find(:first, :conditions => ["project_id=?", member.project_id]) ? "disabled" : ""
  end
  
  def selected_members(classification)
    members = Array.new
    @project.members.all(:order => "users.firstname").each do |m|
      if classification.eql? :stakeholder
        members << m if m.stakeholder
      else
        members << m if m.proj_team
      end
    end
    members.concat(@project.stakeholders.all(:order => "stakeholders.firstname")) if classification.eql?(:stakeholder)
    members
  end

  def available_members(classification)
    members = @project.members.all(:order => "users.firstname")
    members.concat(Stakeholder.all(:order => "stakeholders.firstname")) if classification.eql?(:stakeholder)
    members = members - selected_members(:proj_team) - selected_members(:stakeholder)
    members
  end

end
