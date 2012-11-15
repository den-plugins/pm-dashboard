class ResourceAllocation < ActiveRecord::Base
 
  TYPES =  [['Billable',0],['Non-billable',1],['Project Shadow',2]]  

  belongs_to :member
  
  validates_presence_of :start_date, :end_date, :resource_allocation, :location
  validates_inclusion_of :resource_type, :in => TYPES.map {|t| t[1]}
  attr_protected :member_id
  
  before_save :validate_dates, :validate_overlapping_dates
  
  def validate_dates
    project = member.project
    valid_end_date = []
    project.maintenance_end ? valid_end_date.push(project.maintenance_end, "Maintenance Date") :
                              valid_end_date.push(project.actual_end_date, "Scheduled End Date")
    errors.add(:start_date, 'must be earlier than End Date') if start_date && end_date && (start_date > end_date)
    errors.add(:end_date, "must not be beyond the #{valid_end_date[1]} (#{valid_end_date[0].to_s})") if end_date && valid_end_date[0] && (end_date > valid_end_date[0])
    return false unless errors.empty?
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
