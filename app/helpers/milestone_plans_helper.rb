module MilestonePlansHelper

    def define_state
      case yield
        when 1
          "Planning"
        when 2
          "Active"
        when 3
          "Accepted"
        else
          "<em>Not Set</em>"
      end
    end
end