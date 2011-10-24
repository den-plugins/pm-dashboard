class Highlight < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :highlight
  validates_length_of :highlight, :minimum => 3
  
  named_scope :for_the_week,  lambda {|date| {:conditions => ["created_at between ? and ?", date.beginning_of_week.to_date, date.end_of_week.to_date]}}
  
  def validate
    # project must only have ONE highlight report per week
    date = created_at.to_date
    dup = project.highlights.for_the_week(date).reject{|d| d.id.eql? id}.first

    cfrom, cto = changes['posted_date'].collect if posted_date_changed?

    if (posted_date_changed? && cto) or !posted_date_changed?
      if dup && is_for_next_period && !date.monday.eql?(Date.today.monday + 1.week)
        errors.add_to_base "A post has already been created for that week" unless dup.posted_date.nil?
      elsif dup && !is_for_next_period && !date.monday.eql?(Date.today.monday)
        errors.add_to_base "A post has already been created for that week" unless dup.posted_date.nil?
      end
      
      if is_for_next_period && created_at <= Date.today.end_of_week
        errors.add_to_base "Date must belong to future weeks."
      elsif !is_for_next_period && created_at >= Date.today.end_of_week
        errors.add_to_base "Date must belong to this week or the past weeks."
      end
    end
  end
  
  def self.in_range(project, from, to)
    find(:first, :conditions => ["created_at between ? and ? and project_id = ?", from, to, project])
  end
end
