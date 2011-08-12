class PmDashboardIssueObserver < ActiveRecord::Observer
  def after_create(issue)
    Mailer.deliver_pm_dashboard_issue_add(issue)
  end
end
