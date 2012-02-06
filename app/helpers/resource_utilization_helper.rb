module ResourceUtilizationHelper

  def options_for_period_select(value)
    options_for_select(
                    [[l(:label_this_month), 'current_month'],
                    #[l(:label_last_month), 'last_month'],
                    [l(:label_all_time), 'all'],
                    [l(:label_this_week), 'current_week'],
                    [l(:label_last_week), 'last_week']],
                    value)
  end

  def compute_actual_hours(resource, range)
    resource.spent_time(range.first, range.last) + resource.spent_time_on_admin(range.first, range.last)
  end
end
