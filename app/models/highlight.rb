class Highlight < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :highlight
  validates_length_of :highlight, :minimum => 3
end
