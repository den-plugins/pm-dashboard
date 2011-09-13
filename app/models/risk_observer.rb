class RiskObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_create(risk)
    Mailer.deliver_risk_add(risk)
  end
  
  def before_update(risk)
    @@changed = risk.changed? ? true :  false
  end
  
  def after_update(risk)
    Mailer.deliver_risk_edit(risk) if @@changed
  end

end
