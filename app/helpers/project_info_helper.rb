module ProjectInfoHelper

  def custom_field_headers
    str = ""
    if !@user_custom_fields.nil?
      @user_custom_fields.each do |field|
        str += "<th>#{field.name}</th>" if field.editable
      end
    end
    str
  end

  def selected_members(classification)
    members = Array.new
    @project.members.each do |m|
      if classification.eql? :stakeholder
        members << m if m.stakeholder
      else
        members << m if m.proj_team
      end
    end
    members
  end

  def available_members()
    @project.members - selected_members(:proj_team) - selected_members(:stakeholder)
  end

end
