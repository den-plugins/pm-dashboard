class AddIterationToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :version_id, :integer
  end

end
