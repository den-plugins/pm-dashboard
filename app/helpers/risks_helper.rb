module RisksHelper

  def risk_rating_color_code(rating)
    rating = rating.to_f
    case rating
      when 0 ... 5; "green"
      when 5 ... 15; "yellow"
      when 15 .. 25; "red"
    end
  end
  
  def collection_for_risk_env_select
    Risk::RISK_ENV.keys.collect {|r| [l(Risk::RISK_ENV[r][:name]), r]}
  end
  
  def collection_for_risk_type_select
     Risk::RISK_TYPE.keys.collect {|r| [l(Risk::RISK_TYPE[r][:name]), r]}
  end
  
  def collection_for_risk_status_select
    Risk::STATUS.keys.collect {|r| [l(Risk::STATUS[r][:name]), r ]}
  end
  
  def compute_risk_average(project, risks=nil)
    risks = project.risks.find(:all, :order => 'ref_number DESC') unless risks
    "%0.3f" % ((risks.empty?) ? 0 : Risk.average(:final_risk_rating, :conditions => ["project_id = ?", project]))
  end
  
  def render_probability_guide
    s = content_tag('p', l(:field_probability), :style => 'font-weight: bold;')
    probabilities = Risk::PROBABILITY
    probabilities.keys.sort.each do |k|
      s += content_tag('p', "#{k} - #{l(probabilities[k][:name])}")
    end
    s
  end
  
  def render_impact_guide
    s = content_tag('p', l(:field_impact), :style => 'font-weight: bold;')
    impacts = Risk::IMPACT
    impacts.keys.sort.each do |k|
      s += content_tag('p', "#{k} - #{l(impacts[k][:name])}")
    end
    s
  end
  
end
