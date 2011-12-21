require_dependency 'project'

module Pm
  module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable 
        attr_accessor :validate_client
      
        has_many :assumptions, :dependent => :destroy, :order => "ref_number ASC"
        has_many :pm_dashboard_issues, :dependent => :destroy, :order => "ref_number ASC"
        has_many :risks, :dependent => :destroy, :order => "ref_number ASC"
        has_and_belongs_to_many :stakeholders
        has_many :weeks
        has_many :highlights
        has_many :project_contracts
        
        validates_presence_of :description
        validates_presence_of :client, :if => :validate_client
        validates_numericality_of :contingency,  :only_float => true, :allow_nil => true,
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
          self.planned_start_date -= 2.days if self.planned_start_date.cwday.eql? 7
          self.planned_end_date -= 2.days if self.planned_end_date.cwday.eql? 7
          self.planned_start_date -= 1.day if self.planned_start_date.cwday.eql? 6
          self.planned_end_date -= 1.day if self.planned_end_date.cwday.eql? 6
        end
      end
      
      def weekly_highlights
        h = {}
        pbc= highlights.first(:conditions => ["posted_date is not null and is_for_next_period is false and created_at <= ?", 7.days.ago.end_of_week], :order => 'created_at DESC')
        pac = highlights.first(:conditions => ["posted_date is not null and is_for_next_period is true and created_at <= ?", 7.days.ago.end_of_week], :order => 'created_at DESC')
        
        posted = pbc || pac
        if pbc && pac
          date = (pbc.created_at > pac.created_at) ? pbc.created_at : pac.created_at
        else
          date = posted ? posted.created_at : 7.days.ago.to_date
        end
        
        h[:posted_current] = highlights.for_the_week(date).post_current.first
        h[:posted_after_current] = highlights.for_the_week(date).post_after_current.first
        
        this_week = Date.today.monday
        h[:current] = highlights.first(:conditions => ["is_for_next_period is false and created_at between ? and ?", this_week, (this_week + 6.days)], :order => 'created_at DESC')
        h[:after_current] = highlights.first(:conditions => ["is_for_next_period is true and created_at between ? and ?", this_week, (this_week + 6.days)], :order => 'created_at DESC')
        h
      end
      
      def billing_model
        c = custom_values.detect {|v| v.mgt_custom "Billing Model"}
        c ? c.value : nil
      end

      def current_active_sprint
        versions.find(:first, :conditions => ["state = 2 and sprint_start_date IS NOT NULL"], :order => "effective_date DESC")
      end

      def latest_replanned_end_date
        replanned_end_date = versions.find(:first, :conditions => ["state = 2 and effective_date IS NOT NULL"], 
                                                :order => "effective_date DESC")
        replanned_end_date ? replanned_end_date.effective_date : nil
      end
    end
  end
end
