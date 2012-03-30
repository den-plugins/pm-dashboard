class RenamePmPositionId < ActiveRecord::Migration
  def self.up
    rename_column :members, :pm_pos_id, :pm_position_id
    rename_column :stakeholders, :pm_pos_id, :pm_position_id
  end

  def self.down
    raise IrreversibleMigration
  end
end
