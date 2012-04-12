class AddAccountManagerToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :acct_mngr, :integer
  end

  def self.down
    remove_column :projects, :acct_mngr
  end
end
