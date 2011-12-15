module PmDashboardIssuesHelper

  def issue_impact_color_coding(impact)
    case impact.floor
      when 1; "green"
      when 2; "yellow"
      when 3; "red"
    end
  end
  
  def display_issues_average
    average = @issues ? PmDashboardIssue.average(:impact, :conditions => ["project_id = ? AND date_close IS NULL", @project]) : 0
    h("%0.3f" % average.to_f)
  end

end
