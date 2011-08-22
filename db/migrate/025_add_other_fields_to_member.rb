class AddOtherFieldsToMember < ActiveRecord::Migration

  def self.up
    add_column :members, :phone_no, :string
    add_column :members, :office_no, :string
    add_column :members, :im_id, :string
  end

  def self.down
    remove_column :members, :phone_no
    remove_column :members, :office_no
    remove_column :members, :im_id
  end
end
