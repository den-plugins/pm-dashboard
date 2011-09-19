class ReferenceGenerator
  class << self
    
    def generate(object, pid)
      begin
        object.class.to_s.chars.first + "%0.5d" % pid
      rescue Exception => e
      end
    end

  end
end
