require_dependency 'version'

module Pm
  module VersionPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        const_set(:STATES, {1 => 'Planning', 2 => 'Active', 3 => 'Accepted'})
        const_set(:TYPES, { 0 => "Milestone", 1 => "Development Iteration", 2 => "Build Release"})
        
        validates_inclusion_of :state, :in => Version::STATES.keys, :allow_nil => true
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
    end
  end
end
