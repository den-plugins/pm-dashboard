module AssumptionsHelper

  def collection_for_status_select
    values = Assumption::STATUS
    values.keys.collect{|k| [l(values[k][:name]), k]}
  end
  
  def selected
    @assumption.new_record? ? {:selected => Assumption::STATUS_CLOSED} : {:selected => @assumption.status}
  end
  
  def color_code(p)
    case p
      when 0 ... 50
        "one"
      when 50 ... 100
        "two"
      when 100
        "three"
    end
  end
  
  def assumptions_by_status(status)
    @assumptions.select {|a| a.status == status}
  end
  
  def collection_for_risk_select
    risks = @project.risks.select { |r| !@assumption.risks.include?(r) }
  end
  
end
