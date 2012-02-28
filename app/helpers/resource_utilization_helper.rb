module ResourceUtilizationHelper

  def options_for_period_select_limited(value)
    options_for_select(
                    [[l(:label_this_month), 'current_month'],
                    #[l(:label_last_month), 'last_month'],
                    [l(:label_all_time), 'all'],
                    [l(:label_this_week), 'current_week'],
                    [l(:label_last_week), 'last_week']],
                    value)
  end

  def compute_actual_hours_with_admin(resource, range, include_weekends = false, wnum = nil, total_weeks = nil)
    from, to = range.first, range.last
    if include_weekends
      if wnum == 0
        from, to = @from, (@from.monday + 6.days)
      elsif wnum == (total_weeks - 1)
        to = @to
      else
        to = from.monday + 6.days
      end
    end
    resource.spent_time(from, to, "Billable", include_weekends) + resource.spent_time_on_admin(from, to, "Billable", include_weekends)
  end
end
