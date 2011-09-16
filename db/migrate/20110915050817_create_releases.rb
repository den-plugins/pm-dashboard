class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :releases
  end
end
