class PmPosition < ActiveRecord::Base

  belongs_to :members
  validates_presence_of :name

end
