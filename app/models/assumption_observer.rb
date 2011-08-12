class AssumptionObserver < ActiveRecord::Observer
  def after_create(assumption)
    Mailer.deliver_assumption_add(assumption)
  end
end
