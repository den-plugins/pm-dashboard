class Highlight < ActiveRecord::Base
  belongs_to :project
  validates_length_of :highlight, :minimum => 3, :allow_blank => true, :allow_nil => true
  
  named_scope :for_the_week, lambda {|date| {:conditions => ["created_at between ? and ?", date.beginning_of_week.to_date, date.end_of_week.to_date], :order => "created_at DESC"}}
  named_scope :post_current, :conditions => ["posted_date is not null and is_for_next_period is false"]
  named_scope :post_after_current, :conditions => ["posted_date is not null and is_for_next_period is true"]
  
  def validate
    # project must only have ONE highlight report per week
    date = created_at.to_date
    dup = project.highlights.for_the_week(date).detect {|d| d.is_for_next_period == is_for_next_period && !d.id.eql?(id)}

    cfrom, cto = changes['posted_date'].collect if posted_date_changed?

    if (posted_date_changed? && cto) or !posted_date_changed?
      if dup && !date.monday.eql?(Date.today.monday)
        errors.add_to_base "A post has already been created for this week." unless dup.posted_date.nil?
      end
    end
  end
  
  def after_save
    self.destroy if highlight.blank?
  end
  
  def self.in_range(project, from, to)
    find(:first, :conditions => ["created_at between ? and ? and project_id = ?", from, to, project])
  end
end
