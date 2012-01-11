module TimeLoggingHelper
  
  def color_code_log_time(user)
    "lred" if user[:total_hours_on_selected].to_f < user[:forecasted_hours_on_selected].to_f
  end

  def compute_time_logs(resource, range, acctg)
    from, to = range.first, range.last
    acctg = get_acctg_type(acctg)
    resource.spent_time(from, to, acctg, false) + resource.spent_time_on_admin(from, to, acctg, false)
  end
  
  def display_week(range)
    from, to = range.first, range.last
    s = "%s/" % from.mon + "%s" % from.day + " - " +
           "%s/" % to.mon + "%s" % to.day
  end
  
  def get_acctg_type(acctg)
    case acctg
    when "both"; nil
    when "billable"; "Billable"
    when "non_billable"; "Non-Billable"
    end
  end
  
  def get_string(float)
    "%.2f" % float.to_f    
  end
end
