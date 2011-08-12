module ProjectInfoHelper

  def proj_team(members, classification)
    str = ""
    members.each do |member|
      str += "<tr class='#{cycle('odd', 'even')}'>
        <td>#{member.name}</td>
        <td>#{member.pm_position.name if not member.pm_position.nil?}</td>
        <td>#{member.pm_role.name if not member.pm_role.nil?}</td>
        <td>#{member.user.mail}</td>"
        member.user.custom_field_values.each do |value|
          str += "<td>#{value}</td>" if value.custom_field.editable
        end
      str += "<td>
              #{link_to image_tag('delete.png'), {:controller => 'project_info', :action => 'pm_member_remove', :id => member, :member => {classification => false}},
                                             :confirm => l(:text_are_you_sure),
                                             :method => :post,
                                             :title => 'Remove' }
              </td>
              </tr>"
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
