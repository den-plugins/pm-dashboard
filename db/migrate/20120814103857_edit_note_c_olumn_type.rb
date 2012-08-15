class EditNoteCOlumnType < ActiveRecord::Migration
  def self.up
    rename_column :notes, :type, :note_type
  end

  def self.down
  end
end
