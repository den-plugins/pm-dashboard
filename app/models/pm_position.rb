class PmPosition < ActiveRecord::Base

  has_many :members
  has_many :stakeholders
  
  validates_presence_of :name
  validates_uniqueness_of :name

end
