class ProjectContract < ActiveRecord::Base
  belongs_to :project

  TYPES =  [['Please Select',0],['SOW',1],['CO',2]]
  STATUSES =  [['Please Select',0],['For Sign Off',1],['With Provisional Approval',2],['Signed off',3]]

  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  validates_presence_of :amount, :description
  validates_inclusion_of :pc_type, :in => 1..2
  validates_inclusion_of :status, :in => 1..3

end
