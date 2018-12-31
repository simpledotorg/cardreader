# def patientRequestBody(patient)
#   { id: SecureRandom.uuid,
#     gender: PatientsHelper.to_simple_gender(patient.gender),
#     full_name: patient.full_name,
#     status: 'active',
#     age: patient.age,
#     age_updated_at: { '$ref' => '#/definitions/nullable_timestamp' },
#     created_at: { '$ref' => '#/definitions/timestamp' },
#     updated_at: { '$ref' => '#/definitions/timestamp' } } }
# end

namespace :sync do
  desc 'Sync new patients with simple server'
  task :sync_patients, [:simple_uuid] => :environment do |_t, args|
    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')
    simple_uuid = args[:simple_uuid]

    puts "simple_uuid not set, syncing data for all facilities" unless simple_uuid.present?

    facilities = simple_uuid.present? ? Facility.where(simple_uuid: simple_uuid) : Facility.all

    facilities.each do |facility|
      sync_service = SyncService.new(host, user_id, access_token, facility.simple_uuid)
      patients_to_sync = Patient.where(facility: facility).select(&:unsynced?)
      begin
        sync_service.sync_all(patients_to_sync)
      rescue SyncError
        puts "Error while syncing facility #{facility.name} to Simple Server!"
      end
    end
  end
end