module ProjectInfoHelper

  def proj_team
    str = ""
    @members.each do |member|
      
        str += "<tr class='#{cycle('odd', 'even')}'>
          <td>#{member.name}</td>
          <td>#{}</td>
          <td>#{member.role.name}</td>
          <td>#{member.user.mail}</td>
          <td>#{}</td>
          <td>#{}</td>
          <td>#{}</td>
          <td>#{}</td>
          <td>#{}</td>
        </tr>"
      
    end
    str
  end

end
