class NormalizeDistricts < ActiveRecord::Migration[5.1]
  def change
    add_reference :facilities, :district
    remove_column :facilities, :district
  end
end
