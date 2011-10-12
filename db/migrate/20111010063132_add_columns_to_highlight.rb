class AddColumnsToHighlight < ActiveRecord::Migration
  def self.up
    add_column :highlights, :posted_date, :date
    add_column :highlights, :is_for_next_period, :boolean
  end

  def self.down
    remove_column :highlights, :posted_date
    remove_column :highlights, :is_for_next_period
  end
end
