class AddPositionToStakeholders < ActiveRecord::Migration

  def self.up
    add_column :stakeholders, :stakeholder_position, :string
  end

  def self.down
    remove_column :stakeholders, :stakeholder_position
  end
end
