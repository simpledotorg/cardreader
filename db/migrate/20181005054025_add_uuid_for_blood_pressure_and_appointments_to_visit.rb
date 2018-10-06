class AddUuidForBloodPressureAndAppointmentsToVisit < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :blood_pressure_uuid, :uuid, default: 'uuid_generate_v4()'
    add_column :visits, :appointment_uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
