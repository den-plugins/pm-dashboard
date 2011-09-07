module PmDashboardIssuesHelper

  def issue_impact_color_coding(impact)
    case impact
      when 1; "green"
      when 2; "yellow"
      when 3; "red"
    end
  end

end
