require_dependency 'project'


module ProjectExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
     # belongs_to :deliverable ----- new relationship?
      has_many :assumptions, :dependent => :destroy
      has_many :pm_dashboard_issues
      has_many :risks
    end

  end
  
  module ClassMethods
    
     
    
  end
  
  module InstanceMethods
  
    def assignee(role)
      case role
        when "technical_architect" : id = 13
        when "client" : id = 8
        else id = 0        
      end
      
      if id > 0
        result = self.members.find_by_role_id(id)
      end
      
      return result.nil? ? "None assigned" : result.name
    end
    
  end
end

# Add module to Project
Project.send(:include, ProjectExtn)


