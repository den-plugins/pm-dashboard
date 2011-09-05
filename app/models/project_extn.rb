require_dependency 'project'


module ProjectExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
     # belongs_to :deliverable ----- new relationship?
      has_many :assumptions, :dependent => :destroy, :order => "ref_number ASC"
      has_many :pm_dashboard_issues, :dependent => :destroy, :order => "ref_number ASC"
      has_many :risks, :dependent => :destroy, :order => "ref_number ASC"
      has_and_belongs_to_many :stakeholders

#      validates_presence_of :client
      validates_presence_of :description
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  
    def pm_or_ta(id, project)
      if !id.nil?
        pm = project.members.find_by_user_id(id)
        pm.name
      end
    end

    def validate_client(client)
      errors.add :client, :cant_be_blank if client.empty?
      client.empty?
    end
    
    def update_days_overdue
      assumptions.each { |a| a.save}
      risks.each { |r| r.save }
      pm_dashboard_issues.each { |p| p.save }
    end

  end
end

# Add module to Project
Project.send(:include, ProjectExtn)


