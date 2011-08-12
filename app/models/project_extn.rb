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
  
    def pm_or_ta(id)
      if !id.nil?
        pm = @project.member.find_by_user_id(id)
        pm.name
      end
    end
    
  end
end

# Add module to Project
Project.send(:include, ProjectExtn)


