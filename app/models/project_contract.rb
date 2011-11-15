class ProjectContract < ActiveRecord::Base
  belongs_to :project

  TYPES =  [['Please Select',0],['SOW',1],['CO',2]]
  STATUSES =  [['Please Select',0],['For Sign Off',1],['With Provisional Approval',2],['Signed off',3]]

  attr_accessor :attached_files
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  validates_presence_of :amount, :description
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
end
