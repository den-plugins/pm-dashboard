class PmDashboardIssue < ActiveRecord::Base


  ENV= { "I" => {:name => :label_env_internal },
         "E" => {:name => :label_env_external}}

  IMPACT = { 1 => {:name => :label_issue_impact_low },
             2 => {:name => :label_issue_impact_medium },
             3 => {:name => :label_issue_impact_high }}

  belongs_to :project
  belongs_to :user

  has_and_belongs_to_many :risks
  has_many :assumptions

  validates_presence_of :env, :created_on, :raised_by, :issue_description, :impact, :owner, :project
  validates_inclusion_of :env, :in => ENV.keys
  validates_inclusion_of :impact, :in => IMPACT.keys

  before_save :set_ref_number
  before_update :set_days_overdue

  def set_ref_number
    self.ref_number = "I" + "%0.5d" % id
  end

  def set_days_overdue
    self.days_overdue = (date_due && date_due < Date.today) ? (Date.today - date_due).numerator : 0
  end

end
