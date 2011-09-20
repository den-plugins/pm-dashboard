class ReferenceGenerator
  class << self
    
    def generate(object, pid, char = nil)
      begin
        (char ? char : object.class.to_s.chars.first) + "%0.5d" % pid
      rescue Exception => e
      end
    end

  end
end
