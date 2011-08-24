class PmPosition < ActiveRecord::Base

  has_many :members
  has_many :stakeholders
  
  validates_presence_of :name
  validates_uniqueness_of :name

#  before_save :check_stakeholder

#  def check_stakeholder
#    if @member.stakeholder
#      self.for_stakeholder = true
#    end
#  end

end
