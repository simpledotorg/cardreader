class AddSimpleUuidToFacility < ActiveRecord::Migration[5.2]
  def change
    add_column :facilities, :simple_uuid, :uuid
  end
end
