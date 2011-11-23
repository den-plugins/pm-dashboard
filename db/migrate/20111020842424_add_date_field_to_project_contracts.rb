class AddDateFieldToProjectContracts < ActiveRecord::Migration
  def self.up
    add_column :project_contracts, :effective_from, :date
    add_column :project_contracts, :effective_to, :date
    add_column :project_contracts, :approval_date, :date
  end

  def self.down
    remove_column :project_contracts, :effective_from
    remove_column :project_contracts, :effective_to
    remove_column :project_contracts, :approval_date
  end
end
