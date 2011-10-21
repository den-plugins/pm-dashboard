class AddNonEngrOnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :non_engr_on, :date
  end

  def self.down
    remove_column :users, :non_engr_on
  end
end
