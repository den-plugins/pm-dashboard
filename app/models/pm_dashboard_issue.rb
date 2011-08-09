class PmDashboardIssue < ActiveRecord::Base


  ENV= { "I" => {:name => :label_env_internal },
         "E" => {:name => :label_env_external}}

  belongs_to :project
  belongs_to :user

  has_and_belongs_to_many :risks
  has_many :assumptions

  validates_presence_of :env, :date_raised, :raised_by, :issue_description, :impact, :owner, :project
  validates_inclusion_of :env, :in => ENV.keys
  validates_inclusion_of :impact, :in => %w(Low Medium High)

  before_save :set_ref_number

  def set_ref_number
    self.ref_number = "I" + "%0.5d" % id
  end

end
