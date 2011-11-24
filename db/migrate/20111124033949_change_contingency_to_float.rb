class ChangeContingencyToFloat < ActiveRecord::Migration
  def self.up
    change_column :projects, :contingency, :float
  end

  def self.down
    change_column :projects, :contingency, :integer
  end
end
