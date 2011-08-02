class AddAssumptionsStatus < ActiveRecord::Migration

  def self.up
    add_column :assumptions, :status, :string
  end
  
  def self.down
    remove_column :assumptions, :status
  end
end
