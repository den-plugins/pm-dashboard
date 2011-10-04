require_dependency 'project'

module ProjectExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      attr_accessor :validate_client
      
      has_many :assumptions, :dependent => :destroy, :order => "ref_number ASC"
      has_many :pm_dashboard_issues, :dependent => :destroy, :order => "ref_number ASC"
      has_many :risks, :dependent => :destroy, :order => "ref_number ASC"
      has_and_belongs_to_many :stakeholders
      has_many :weeks
      has_many :highlights
      
      validates_presence_of :description
      validates_presence_of :client, :if => :validate_client
      validates_numericality_of :contingency,  :only_integer => true, :allow_nil => true,
                                                     :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100, 
                                                     :message => 'should only be from 0 to 100'
      before_save :validate_dates

    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  
    def pm_or_ta(id, project)
      if !id.nil?
        pm = project.members.find_by_user_id(id)
        pm.name unless pm.nil?
      end
    end
    
    def update_days_overdue
      assumptions.each { |a| a.update_days_overdue }
      risks.each { |r| r.update_days_overdue }
      pm_dashboard_issues.each { |p| p.update_days_overdue }
    end

    def validate_dates
      if self.planned_start_date and self.planned_end_date
        self.planned_start_date, self.planned_end_date = self.planned_end_date, self.planned_start_date if self.planned_start_date > self.planned_end_date
        self.planned_start_date -= 2.days if self.planned_start_date.cwday.eql? 7
        self.planned_end_date -= 2.days if self.planned_end_date.cwday.eql? 7
        self.planned_start_date -= 1.day if self.planned_start_date.cwday.eql? 6
        self.planned_end_date -= 1.day if self.planned_end_date.cwday.eql? 6
      end
    end

  end
end

# Add module to Project
Project.send(:include, ProjectExtn)


