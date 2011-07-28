class Assumption < ActiveRecord::Base

  belongs_to :project
  belongs_to :user
  
  validates_presence_of :description, :project, :ref_number
end
