class AssumptionObserver < ActiveRecord::Observer
  
  @@changed = false
  
  def after_create(assumption)
    Mailer.deliver_assumption_add(assumption)
  end
  
  def before_update(assumption)
    assumption.changes.delete_if {|k| k.eql? "updated_on" or k.eql?  "days_overdue"}
    @@changed = assumption.changed? ? true :  false
  end
  
  def after_update(assumption)
    Mailer.deliver_assumption_edit(assumption) if @@changed
  end

end
