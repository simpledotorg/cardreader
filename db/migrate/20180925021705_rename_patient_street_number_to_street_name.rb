class RenamePatientStreetNumberToStreetName < ActiveRecord::Migration[5.2]
  def change
    rename_column :patients, :street_number, :street_name
  end
end
