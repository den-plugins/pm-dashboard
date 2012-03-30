class Stakeholder < ActiveRecord::Base

  has_and_belongs_to_many :projects
  belongs_to :pm_role
  belongs_to :pm_position

  validates_presence_of :firstname, :lastname
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i
  validates_length_of :firstname, :lastname, :maximum => 30
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_nil => true
  validates_length_of :mail, :maximum => 60, :allow_nil => true
  validates_format_of :phone_no, :office_no, :with => /^[0-9]*$/i, :allow_nil => true
  validates_length_of :phone_no, :office_no, :maximum => 15, :allow_nil => true

  def name
    "#{self.firstname} #{self.lastname}"
  end

  def pmposition
    pm_position ? pm_position.name : nil
  end

  def pmrole
    pm_role ? pm_role.name : nil
  end

end
