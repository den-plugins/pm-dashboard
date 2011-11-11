class CreateProjectContracts < ActiveRecord::Migration
  def self.up
    create_table :project_contracts do |t|
      t.column :pc_type, :integer
      t.column :description, :string
      t.column :amount, :float
      t.column :status, :integer
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :project_contracts
  end	
end
