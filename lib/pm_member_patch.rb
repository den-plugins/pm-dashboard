require_dependency 'member'

module Pm
  module MemberPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        has_many :resource_allocations, :dependent => :destroy, :order => "start_date ASC"
        has_many :time_entries, :through => :user
        belongs_to :pm_role
        belongs_to :pm_position

        validates_format_of :phone_no, :office_no, :with => /^[0-9]*$/i, :allow_nil => true
        validates_length_of :phone_no, :office_no, :maximum => 15, :allow_nil => true
        
        named_scope :stakeholders, :include => [:user], :conditions => "stakeholder = true", :order => "users.firstname"
        named_scope :project_team, :include => [:user], :conditions => "proj_team = true", :order => "users.firstname"
        
        before_update :remove_if_no_timelogs, :if => "proj_team_changed?"
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def remove_if_no_timelogs
        from, to = changes["proj_team"]
        if from && !to
          return false if time_entries.find(:first, :conditions => ["#{TimeEntry.table_name}.project_id=?", project_id])
        end
      end
      
      def mail
        self.user.mail
      end

      def pmposition
        pm_position ? pm_position.name : nil
      end

      def pmrole
        pm_role ? pm_role.name : nil
      end
      
      def days_and_cost(week, rate = nil, count_shadow=true, acctg='Billable')
        days, cost = 0, 0
        allocations = resource_allocations
        unless allocations.empty?
          week.each do |day|
            unless day.wday.eql?(0) || day.wday.eql?(6)
              allocation = allocations.detect{ |a| a.start_date <= day && a.end_date >= day}
              holiday = allocation.nil? ? 0 : detect_holidays_in_week(allocation.location, day)
              if allocation and !allocation.resource_allocation.eql?(0) and holiday.eql?(0)
                if count_shadow
                  days += (1 * (allocation.resource_allocation.to_f/100).to_f)
                else
                  case acctg.downcase
                  when 'billable'
                    # count only days where member is Billable
                    days += (1 * (allocation.resource_allocation.to_f/100).to_f) if allocation.resource_type.eql?(0)
                  when 'non-billable'
                    #count only days where member is Non-billable
                    days += (1 * (allocation.resource_allocation.to_f/100).to_f) if allocation.resource_type.eql?(1)
                  when 'both'
                    # count days where member is not a shadow
                    days += (1 * (allocation.resource_allocation.to_f/100).to_f) if allocation.resource_type.eql?(0) or allocation.resource_type.eql?(1)
                  end
                end
              end
            end
          end
        end
        cost = days * (rate.to_f)
        rate ? [days, cost] : days
      end
      
      def is_shadowed?(day)
        if a = resource_allocations.detect{ |a| a.start_date <= day && a.end_date >= day}
          a.resource_type.eql?(2)
        end
      end
      
      def detect_holidays_in_week(location, day)
        locations = [6]
        locations << location if location
        locations << 3 if location.eql?(1) || location.eql?(2)
        Holiday.count(:all, :conditions => ["event_date=? and location in (#{locations.join(', ')})", day])
      end
      
      def billable?(from=nil, to=nil)
        from, to = project.planned_start_date, project.planned_end_date unless from && to
        return false if from.nil? or to.nil?
        allocations = resource_allocations.select {|a| (from..to).to_a & (a.start_date..a.end_date).to_a}
        if allocations.empty?
          false
        else
          allocations.reject {|r| !r.resource_type.eql?(0) || r.resource_allocation.eql?(0)}.empty? ? false : true
        end
      end
      
      def allocated?(date=nil)
        return false if date.nil?
        allocations = resource_allocations.find(:all, :conditions=>["? BETWEEN start_date and end_date", date])
        if allocations.empty?
          false
        else
          allocations.reject {|r| !r.resource_type.eql?(0) || r.resource_allocation.eql?(0)}.empty? ? false : true
        end       
      end

      def spent_time(from, to, acctg=nil, include_weekends=false)
        if from && to
          spent = time_entries.find(:all, :select => "hours, spent_on", :include => [:issue],
                                                :conditions => ["#{TimeEntry.table_name}.project_id = ? and spent_on between ? and ?", project_id, from, to])

          spent = spent.select {|s| s.issue.accounting.name.casecmp(acctg) == 0} if acctg
          if include_weekends
            spent.sum{|s| s.hours}
          else
            spent.sum{|s| s.spent_on.wday.eql?(0) || s.spent_on.wday.eql?(6) ? 0 : s.hours}
          end
        end
      end
      
      def with_complete_logs?(range)
        allocated = days_and_cost(range) * 8
        actual = spent_time(range.first, range.last)
        closest_admins = project.closest_admins
        unless closest_admins.empty?
          closest_admins.each do |sibling|
            if m = sibling.members.detect {|m| m.user_id.eql?(user_id) }
              actual += m.spent_time(range.first, range.last)
            end
          end
        end
        actual >= allocated
      end

      def spent_time_on_admin(from, to, acctg = nil, include_weekends = false)
        actuals_on_admin = 0
        closest_admins = project.closest_admins
        unless closest_admins.empty?
          closest_admins.each do |sibling|
            if m = sibling.members.detect {|m| m.user_id.eql?(user_id) }
              actuals_on_admin += m.spent_time(from, to, acctg, include_weekends)
            end
          end
        end
        actuals_on_admin
      end
    
    end
  end
end
