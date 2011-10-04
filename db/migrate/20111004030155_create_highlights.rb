class CreateHighlights < ActiveRecord::Migration
  def self.up
    create_table :highlights do |t|
      t.column :project_id, :integer
      t.column :highlight, :text
      t.column :created_on, :date

      t.timestamps
    end
  end

  def self.down
    drop_table :highlights
  end
end
