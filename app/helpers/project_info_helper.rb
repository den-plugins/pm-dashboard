module ProjectInfoHelper

  def pm_members(members, classification)
    str = ""
    members.each do |member|
      remote_form_for(:member, member, :url => {:controller => 'project_info', :action => 'update_pos_role', :member_id => member}, :method => :post, :html => {:id => "classification_#{member.id}"}) do |f|
      
        str += "<tr class='#{cycle('odd', 'even')}'>
          <td>#{member.name}</td>
          <td>
          #{f.select :pm_position, (@positions.collect {|p| [p.name, p.id]}), {:include_blank => 'Others'}, :required => true}
          </td>
          <td>#{f.select :pm_position, (@roles.collect {|r| [r.name, r.id]}), {:include_blank => 'Others'}, :required => true}</td>
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
