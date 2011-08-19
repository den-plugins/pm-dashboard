require_dependency 'user'


module UserExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable 
      has_many :assumptions, :foreign_key => :owner
      has_many :risks, :foreign_key => :owner
      has_many :pm_dashboard_issues, :foreign_key => :owner
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

User.send(:include, UserExtn)


