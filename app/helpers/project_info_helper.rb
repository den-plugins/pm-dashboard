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

end
