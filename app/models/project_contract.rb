class ProjectContract < ActiveRecord::Base
  belongs_to :project

  TYPES =  [['Please Select',0],['SOW',1],['CO',2]]
  STATUSES =  [['Please Select',0],['For Sign Off',1],['With Provisional Approval',2],['Signed off',3]]

  acts_as_attachable 
end
