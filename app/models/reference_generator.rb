class ReferenceGenerator
  class << self
    
    def generate(object, pid)
      begin
        object.class.to_s.chr + "%0.5d" % pid
      rescue Exception => e
      end
    end

  end
end
