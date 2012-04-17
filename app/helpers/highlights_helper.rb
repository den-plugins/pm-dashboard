module HighlightsHelper
  
  def recently_posted_date(highlight, highlight_next)
    if highlight
      highlight.created_at.to_date
    elsif highlight.nil? && highlight_next
      highlight_next.created_at.to_date
    elsif highlight.nil? && highlight_next.nil?
      params[:select_week] ? params[:select_week] : 7.days.ago.to_date
    end
  end
  
  def render_highlight_actions(period, highlight)
    links = ""
    links << link_to_remote("Save", {:url => {:action => 'save', :controller => 'highlights', :id => highlight, :project_id => @project},
                                                                :with => "Form.serialize('#{period}_highlight_form')",
                                                                :loading => "$('ajax-indicator').show()",
                                                                :complete => "$('ajax-indicator').hide()" },
                                                                :class => 'icon icon-save', :id => '#{period}_save_button')
    if highlight && highlight.posted_date
      links << link_to_remote("Unpost", {:url => {:action => 'unpost', :controller => 'highlights', :id => highlight, :project_id => @project},
                                                                      :with => "Form.serialize('nextp_highlight_form')",
                                                                      :loading => "$('ajax-indicator').show()",
                                                                      :complete => "$('ajax-indicator').hide()" },
                                                                      :class => 'icon icon-unpost')
    else
      links << link_to_remote("Post", {:url => {:action => 'post', :controller => 'highlights', :id => highlight, :project_id => @project},
                                                                 :with => "Form.serialize('#{period}_highlight_form')",
                                                                 :loading => "$('ajax-indicator').show()",
                                                                 :complete => "$('ajax-indicator').hide()" },
                                                                 :class => 'icon icon-checked')
    end
    links << link_to_remote("Cancel", {:url => {:action => 'save', :controller => 'highlights', :project_id => @project, :cancel => true}}, :class => "icon icon-cancel")
  end
  
  def render_highlight_message highlight, message
    if highlight && !highlight.new_record?
      content_tag 'p', textilizable(highlight.highlight)
    else
      content_tag 'p', h(message), :class => 'nodata'
    end
  end
    
  def select_by_week_options
    if start_date = @project.planned_start_date and end_date = @project.planned_end_date
      options_for_select (start_date .. end_date).collect {|d| "#{format_date d.beginning_of_week} - #{format_date d.end_of_week}"}.uniq
    elsif @project.highlights.present?
      start_date = @project.highlights.first(:order => 'created_at ASC').created_at
      options_for_select (start_date .. Date.today).collect {|d| "#{format_date d.beginning_of_week} - #{format_date d.end_of_week}"}.uniq
    else
      options_for_select ["Not Applicable"]
    end
  end
  
  def state_the_time(params)
    if params[:time_state].eql?('current') || params[:time_state].eql?('nextp')
      params[:time_state]
    else
      params[:highlight][:is_for_next_period] ? 'nextp' : 'current'
    end
  end
  
end
