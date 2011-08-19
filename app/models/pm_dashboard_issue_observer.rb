class PmDashboardIssueObserver < ActiveRecord::Observer

  @@changed = false
  
  def after_create(issue)
    Mailer.deliver_pm_dashboard_issue_add(issue)
  end
  
  def before_update(assumption)
    @@changed = true if assumption.changed?
  end

  def after_update(issue)
    Mailer.deliver_pm_dashboard_issue_edit(issue)
  end

end
