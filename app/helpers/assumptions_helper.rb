module AssumptionsHelper

  def collection_for_status_select
    values = Assumption::STATUS
    values.keys.collect{|k| [l(values[k][:name]), k]}
  end
  
  def selected
    @assumption.new_record? ? {:selected => Assumption::STATUS_CLOSED} : {:selected => @assumption.status}
  end
  
  def assumptions_by_status(status)
    @assumptions.select {|a| a.status == status}
  end
  
  def assumptions_overdued
    @assumptions.select {|b| !b.days_overdue.nil?}
  end
  
end
