class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :project_id
      t.text :text
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
