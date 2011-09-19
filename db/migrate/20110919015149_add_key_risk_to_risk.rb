class AddKeyRiskToRisk < ActiveRecord::Migration
  def self.up
    add_column :risks, :key_risk, :boolean
  end

  def self.down
    remove_column :risks, :key_risk
  end
end
