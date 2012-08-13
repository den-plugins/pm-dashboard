class NotesController < PmController
 
  menu_item :notes

  #before_filter :authorize
  #before_filter :role_check_client
  
  include NotesHelper

  def index

  end

end
