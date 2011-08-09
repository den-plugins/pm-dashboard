module RisksHelper

  def risk_rating_color_code(rating)
    case rating
      when 0 ... 5
        "green"
      when 5 ... 15
        "yellow"
      when 15 .. 25
        "red"
    end
  end
  
end
