class AddDiagnosedWithHyperTensionToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :diagnosed_with_hypertension, :boolean
  end
end
