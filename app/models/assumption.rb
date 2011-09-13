class Assumption < ActiveRecord::Base

  STATUS_OPEN = "open"
  STATUS_CLOSED = "closed"
  STATUS = {  STATUS_OPEN => {:name => :label_assumptions_status_open},
                         STATUS_CLOSED => {:name => :label_assumptions_status_closed}}
  
  belongs_to :project
  belongs_to :user, :foreign_key => :owner, :class_name => 'User'
  has_and_belongs_to_many :risks
  
  attr_protected :ref_number, :pid, :days_overdue, :date_closed, :project_id, :updated_on
  
  validates_presence_of :description, :project, :owner, :date_due
  validates_inclusion_of :status, :in => STATUS.keys
  validates_numericality_of :days_overdue, :allow_nil => true
  
  before_create :set_ref_number
  before_save :update_date_closed
  before_save :update_status

  def set_ref_number
    last = @project.assumptions.find(:last, :order => 'pid ASC')
    self.pid = (last.nil?) ? 1 : last.pid+1
    self.ref_number = "A" + "%0.5d" % pid
  end
  
  def update_status
    if risk_ids.any? && status.eql?(STATUS_OPEN)
      self.status = STATUS_CLOSED
      self.date_closed = Date.today
    end
  end
  
  def update_date_closed
    if status_changed?
      self.date_closed = status.eql?(STATUS_CLOSED) ? Date.today : nil
    end
  end
  
  def update_days_overdue
    self.days_overdue = (date_due < Date.today && validation.blank?) ? (Date.today - date_due).numerator : 0
    self.send(:update_without_callbacks)
  end

end
