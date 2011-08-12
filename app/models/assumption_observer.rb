class AssumptionObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_save(assumption)
    Mailer.deliver_assumption_add(assumption)
  end
  
  def before_update(assumption)
    @@changed = true if assumption.changed?
    @@changed = false if assumption.ref_number_changed?
  end
  
  def after_update(assumption)
    Mailer.deliver_assumption_edit(assumption) if @@changed
  end

end
