class RiskObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_create(risk)
    Mailer.deliver_risk_add(risk)
  end
  
  def before_update(risk)
    risk.changes.delete_if {|k| k.eql? "updated_on" or k.eql?  "days_overdue"}
    @@changed = risk.changed? ? true :  false
  end
  
  def after_update(risk)
    Mailer.deliver_risk_edit(risk) if @@changed
  end

end
