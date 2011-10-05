class Highlight < ActiveRecord::Base

  belongs_to :project
  
  validates_presence_of :highlight
  validates_length_of :highlight, :maximum => 140
  
  named_scope :this_week, :conditions => ["created_at between ? and ? ", Date.today.beginning_of_week, Date.today.end_of_week],
                                                  :order => "created_at DESC"
end
