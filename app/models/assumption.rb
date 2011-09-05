class Assumption < ActiveRecord::Base

  STATUS_OPEN = "open"
  STATUS_CLOSED = "closed"
  STATUS = {  STATUS_OPEN => {:name => :label_assumptions_status_open},
                         STATUS_CLOSED => {:name => :label_assumptions_status_closed}}
  
  belongs_to :project
  belongs_to :user, :foreign_key => :owner, :class_name => 'User'
  has_and_belongs_to_many :risks
  
  validates_presence_of :description, :project, :owner, :date_due
  validates_inclusion_of :status, :in => STATUS.keys
  validates_numericality_of :days_overdue, :allow_nil => true

  before_create :set_ref_number
  before_save :update_days_overdue
  before_save :set_to_conditions

  def set_ref_number
    last = @project.assumptions.find(:last, :order => 'pid ASC')
    self.pid = (last.nil?) ? 1 : last.pid+1
    self.ref_number = "A" + "%0.5d" % pid
  end
  
  def set_to_conditions
    self.status = STATUS_CLOSED unless risk_ids.empty?
    self.date_closed = (status.eql? STATUS_CLOSED) ?  Date.today.to_s : nil
  end
  
  def update_days_overdue
    self.days_overdue = (date_due < Date.today && validation.blank?) ? (Date.today - date_due).numerator : 0
  end

end
