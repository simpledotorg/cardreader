class AddUuidForPatientAddressAndPhoneNumberToPatients < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'uuid-ossp'
    add_column :patients, :patient_uuid, :uuid, default: 'uuid_generate_v4()'
    add_column :patients, :address_uuid, :uuid, default: 'uuid_generate_v4()'
    add_column :patients, :phone_uuid, :uuid, default: 'uuid_generate_v4()'
    add_column :patients, :alternate_phone_uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
