class ProjectContract < ActiveRecord::Base
  belongs_to :project

  TYPES =  [['Please Select',0],['SOW',1],['CO',2]]
  STATUSES =  [['Please Select',0],['For Sign Off',1],['With Provisional Approval',2],['Signed off',3]]

  before_save :validate_dates

  attr_accessor :attached_files
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  validates_presence_of :amount, :description, :effective_from, :effective_to #, :approval_date
  validates_inclusion_of :pc_type, :in => 1..2
  validates_inclusion_of :status, :in => 1..3
  
  def before_validation
    if attached_files && attached_files.is_a?(Hash)
      attached_files.each_value do |attachment|
        file = attachment['file']
        next unless file && file.size > 0
          attachments.build :container => self,
                                            :file => file,
                                            :description => attachment['description'].to_s.strip,
                                            :author => User.current
      end
    end
  end
  
  def validate
    attachments.each do |attachment|
      errors.add_to_base :file_not_pdf if !attachment.is_pdf? || !attachment.valid?
    end unless attachments.empty?
  end
  
  def validate_dates
    if effective_from && effective_to && (effective_from > effective_to)
      errors.add(:effective_from, 'must be earlier than Effective to')
      return false
    end
  end
end
