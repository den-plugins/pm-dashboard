class AssumptionObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_create(assumption)
    Mailer.deliver_assumption_add(assumption)
  end
  
  def before_update(assumption)
    @@changed = true if assumption.changed?
  end
  
  def after_update(assumption)
    Mailer.deliver_assumption_edit(assumption) if @@changed
  end

end
