class PmRole < ActiveRecord::Base

  has_many :members
  has_many :stakeholders
  
  validates_presence_of :name
  validates_uniqueness_of :name

#  before_save :check_stakeholder

  def check_stakeholder(member)
    if member.is_a?(Stakeholder) or member.stakeholder
      self.for_stakeholder = true
    end
  end

end
