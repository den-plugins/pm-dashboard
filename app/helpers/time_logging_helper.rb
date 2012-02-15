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
  
  def options_for_period_select(value)
    options_for_select([
            [l(:label_this_month), 'current_month'],
            [l(:label_all_time), 'all'],
            [l(:label_today), 'today'],
            [l(:label_yesterday), 'yesterday'],
            [l(:label_this_week), 'current_week'],
            [l(:label_last_week), 'last_week'],
            [l(:label_last_n_days, 7), '7_days'],
            [l(:label_last_month), 'last_month'],
            [l(:label_last_n_days, 30), '30_days'],
            [l(:label_this_year), 'current_year']],
            value)
  end
end
