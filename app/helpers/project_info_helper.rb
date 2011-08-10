module ProjectInfoHelper

  def proj_team
    str = ""
    @members.each do |member|
      
        str += "<tr class='#{cycle('odd', 'even')}'>
          <td>#{member.name}</td>
          <td>#{member.role.name}</td>
          <td>#{member.user.mail}</td>"
          member.user.custom_field_values.each do |value|
            str += "<td>#{value}</td>" if value.custom_field.editable
          end
        str += "</tr>"
      
    end
    str
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

end
