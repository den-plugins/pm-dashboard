require_dependency 'member'


module MemberExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable 

      belongs_to :pm_role
      belongs_to :pm_position
      
    end

  end
  
  module ClassMethods

  end
  
  module InstanceMethods

    def pmposition
      pmposition = nil
      PmPosition.all.each do |pos|
        if pos.id == self.pm_pos_id
          pmposition = pos.name if !self.pm_pos_id.nil?
        end
      end
      pmposition
    end

    def pmrole
      pmrole = nil
      PmRole.all.each do |role|
        if role.id == self.pm_role_id
          pmrole = role.name if !self.pm_role_id.nil?
        end
      end
      pmrole
    end
  end
end

# Add module to Project
Member.send(:include, MemberExtn)


