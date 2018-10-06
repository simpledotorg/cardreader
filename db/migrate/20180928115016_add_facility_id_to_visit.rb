class AddFacilityIdToVisit < ActiveRecord::Migration[5.2]
  def change
    add_reference :visits, :facilities
  end
end
