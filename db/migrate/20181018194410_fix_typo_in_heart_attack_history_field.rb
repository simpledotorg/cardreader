class FixTypoInHeartAttackHistoryField < ActiveRecord::Migration[5.2]
  def change
    rename_column :patients, :heard_attack_in_last_3_years, :heart_attack_in_last_3_years
  end
end
