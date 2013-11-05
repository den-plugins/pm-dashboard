class UpdateContractStatusInProjectContracts < ActiveRecord::Migration
  def self.up
    change_column :project_contracts, :contract_status, :integer, :default => 1
  end

  def self.down
    remove_column :project_contracts, :contract_status
  end
end
