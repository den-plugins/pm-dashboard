class ResourceAllocation < ActiveRecord::Base
 
  TYPES =  [['Billable',0],['Non-billable',1],['Project Shadow',2]]  

  belongs_to :member
  
  validates_presence_of :start_date, :end_date, :resource_allocation
  attr_protected :member_id
  
  before_save :validate_dates, :validate_overlapping_dates
  
  def validate_dates
    if start_date && end_date && (start_date > end_date)
      errors.add(:start_date, 'must be earlier than End Date')
      return false
    end
  end
  
  def validate_overlapping_dates
    if start_date && end_date
      ranges = member.resource_allocations.find(:all, :select => "id, start_date, end_date").collect{|k| (k.start_date .. k.end_date) unless k.id.eql? id }.compact
      ranges.each do |range|
        if (range.include?(start_date) || range.include?(end_date))
          errors.add_to_base( " Date overlapped with an existing date range")
          return false
        end
      end
    end
  end
end
