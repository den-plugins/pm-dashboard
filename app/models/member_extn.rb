require_dependency 'member'


module MemberExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable 

      has_one :pm_role
      has_one :pm_position
      
    end

  end
  
  module ClassMethods

  end
  
  module InstanceMethods
    
  end
end

# Add module to Project
Member.send(:include, MemberExtn)


