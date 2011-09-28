require_dependency 'member'


module MemberExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable 
      
      has_many :resource_allocations, :dependent => :destroy, :order => "start_date ASC"
      belongs_to :pm_role
      belongs_to :pm_position

      validates_format_of :phone_no, :office_no, :with => /^[0-9]*$/i, :allow_nil => true
      validates_length_of :phone_no, :office_no, :maximum => 15, :allow_nil => true
      
      named_scope :stakeholders, :conditions => "stakeholder = true", :order => "users.firstname"
      named_scope :project_team, :conditions => "proj_team = true", :order => "users.firstname"
      
    end

  end
  
  module ClassMethods

  end
  
  module InstanceMethods

    def mail
      self.user.mail
    end

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
    
    def days_and_cost(week, rate)
      days, cost = 0, 0
      week.each do |day|
        allocation = resource_allocations.find(:first, :conditions => ["start_date <= ? and end_date >= ?", day, day])
        if allocation and !allocation.resource_allocation.eql? 0
          days += (1 * (allocation.resource_allocation.to_f/100).to_f)
        end
      end
      cost = days * (rate.to_f)
      [days, cost]
    end
  end
end

# Add module to Project
Member.send(:include, MemberExtn)


