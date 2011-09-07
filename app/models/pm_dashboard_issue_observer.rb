class PmDashboardIssueObserver < ActiveRecord::Observer

  @@changed = false
  
  def after_create(issue)
    Mailer.deliver_pm_dashboard_issue_add(issue)
  end
  
  def before_update(issue)
    issue.changes.delete_if {|k| k.eql? "updated_on" or k.eql?  "days_overdue"}
    @@changed = issue.changed? ? true :  false
  end

  def after_update(issue)
    Mailer.deliver_pm_dashboard_issue_edit(issue) if @@changed
  end

end
