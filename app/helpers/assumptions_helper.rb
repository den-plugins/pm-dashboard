module AssumptionsHelper

  def collection_for_status_select
    values = Assumption::STATUS
    values.keys.collect{|k| [l(values[k][:name]), k]}
  end
  
  def selected
    @assumption.new_record? ? {:selected => Assumption::STATUS_OPEN} : {:selected => @assumption.status}
  end
  
  def color_code(percentage)
    case percentage
      when 0 ... 50; "red"
      when 50 ... 100; "yellow"
      when 100; "green"
    end
  end
  
  def assumptions_by_status(status)
    @assumptions.select {|a| a.status == status}
  end

end
