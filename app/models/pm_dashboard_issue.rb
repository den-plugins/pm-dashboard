class PmDashboardIssue < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  validates_presence_of :env, :issue_description, :action, :impact, :project, :owner, :date_due
  validates_inclusion_of :status, :in => %w(open closed)
  validates_inclusion_of :env, :in => %w(I E)
  validates_inclusion_of :impact, :in => 1..3

  before_save :set_ref_number
  before_save :set_status
  before_save :set_raised_by

  def set_ref_number
    self.ref_number = "I" + "%0.5d" % id
  end

  def set_status
    self.date_closed = Date.today.to_s if status.eql? "close"
  end

  def set_raised_by
    self.raised_by = User.current
  end

end
