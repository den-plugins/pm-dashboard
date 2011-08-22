class CreateStakeholders < ActiveRecord::Migration
  
  def self.up
    create_table :stakeholders do |t|
      t.column :firstname, :string
      t.column :lastname, :string
      t.column :pm_pos_id, :integer
      t.column :pm_role_id, :integer
      t.column :mail, :string
      t.column :phone_no, :string
      t.column :office_no, :string
      t.column :im_id, :string
      
      t.timestamps
    end
  end

  def self.down
    drop_table :stakeholders
  end
end
