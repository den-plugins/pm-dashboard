class PmDashboardIssueObserver < ActiveRecord::Observer
  def after_create(issue)
    Mailer.deliver_pm_dashboard_issue_add(issue)
  end

def after_update(issue)
    Mailer.deliver_pm_dashboard_issue_edit(issue)
  end

end
