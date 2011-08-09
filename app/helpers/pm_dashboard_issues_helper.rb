module PmDashboardIssuesHelper

  def collection_for_issues_risk_select
    risks = @project.risks.select { |r| !@issue.risks.include?(r) }
  end

  def collection_for_assumption_select
    assumptions = @project.assumptions.select { |r| !@issue.assumptions.include?(r) }
  end

end
