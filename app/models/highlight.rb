class Highlight < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :highlight
end
