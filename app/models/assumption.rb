class Assumption < ActiveRecord::Base

  STATUS_OPEN = "open"
  STATUS_CLOSED = "closed"
  STATUS = {  STATUS_OPEN => {:name => :label_assumptions_status_open},
                         STATUS_CLOSED => {:name => :label_assumptions_status_closed}}
  
  belongs_to :project
  has_one :user
  has_and_belongs_to_many :risks
  
  validates_presence_of :description, :project, :owner, :date_due
  validates_inclusion_of :status, :in => STATUS.keys
  validates_numericality_of :days_overdue, :allow_nil => true
  validate :date_due_not_past

  before_save :set_ref_number
  before_save :set_date_closed
  
  def set_ref_number
    self.ref_number = "A" + "%0.5d" % id
  end
  
  def set_date_closed
    self.date_closed = Date.today.to_s if status.eql? STATUS_CLOSED
  end
  
  def date_due_not_past
    errors.add(:date_due, 'is in the past') if date_due and date_due.past?
  end
  
end
