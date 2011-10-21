module HighlightsHelper
  
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
  
end
