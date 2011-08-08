module RisksHelper

  def collection_status
    values = Risk::STATUS
    values.keys.collect {|r| [l(values[r][:name]), r ]}
  end
  
end
