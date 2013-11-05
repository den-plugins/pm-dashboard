class AddContractStatusToProjectContracts < ActiveRecord::Migration
  def self.up
    add_column :project_contracts, :contract_status, :integer
  end

  def self.down
    remove_column :project_contracts, :contract_status
  end
end
