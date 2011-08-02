class Assumption < ActiveRecord::Base

  belongs_to :project
  has_one :user
  
  validates_presence_of :description, :project, :owner, :date_due
  validates_inclusion_of :status, :in => %w(open closed)

  before_save :set_ref_number
  before_save :set_status
  
  def set_ref_number
    self.ref_number = "A" + "%0.5d" % id    
  end
  
  def set_status
    self.date_closed = Date.today.to_s if status.eql? "close"
  end
end
