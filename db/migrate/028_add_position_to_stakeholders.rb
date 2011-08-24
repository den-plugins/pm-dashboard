class AddPositionToStakeholders < ActiveRecord::Migration

  def self.up
    add_column :stakeholders, :position, :string
  end

  def self.down
    remove_column :stakeholders, :position
  end
end
