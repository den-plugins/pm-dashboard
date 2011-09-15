class ResourceAllocation < ActiveRecord::Base
  belongs_to :member
  
  validates_presence_of :start_date, :end_date, :resource_allocation
  attr_protected :member_id
  
  before_save :validate_dates
  
  def validate_dates
    if start_date && end_date && (start_date > end_date || start_date == end_date)
      errors.add(:start_date, 'must be earlier than End Date')
      return false
    end
  end
end
