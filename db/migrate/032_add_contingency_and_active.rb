class AddContingencyAndActive < ActiveRecord::Migration

  def self.up
    add_column :projects, :active, :string
    add_column :projects, :contingency, :integer
  end

  def self.down
    remove_column :projects, :active
    remove_column :projects, :contingency
  end
end
