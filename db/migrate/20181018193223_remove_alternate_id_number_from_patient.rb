class RemoveAlternateIdNumberFromPatient < ActiveRecord::Migration[5.2]
  def change
    remove_column :patients, :alternate_id_number, :string
  end
end
