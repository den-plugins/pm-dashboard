class AssumptionObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_create(assumption)
    Mailer.deliver_assumption_add(assumption)
  end
  
  def before_update(assumption)
    @@changed = assumption.changed? ? true :  false
  end
  
  def after_update(assumption)
    Mailer.deliver_assumption_edit(assumption) if @@changed
  end

end
