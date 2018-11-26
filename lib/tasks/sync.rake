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
  desc 'Sync patients data with simple server'
  task :sync_patients, [:simple_uuid] => :environment do |_t, args|
    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')
    simple_uuid = args[:simple_uuid]

    puts "simple_uuid not set, syncing data for all facilities" unless simple_uuid.present?

    facilities = simple_uuid.present? ? Facility.where(simple_uuid: simple_uuid) : Facility.all
    patients = Patient.where(facility: facilities).reject(&:synced?)

    sync_service = SyncService.new(host, user_id, access_token)
    sync_service.sync(patients)
  end

  desc 'Sync prescription drug data with simple server'
  task :sync_prescription_drugs, [:simple_uuid] => :environment do |_t, args|
    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')
    simple_uuid = args[:simple_uuid]

    unless simple_uuid.present?
      puts "simple_uuid not set; exiting."
      next
    end

    since = Time.new(0)
    facilities = simple_uuid.present? ? Facility.where(simple_uuid: simple_uuid) : Facility.all

    patients = Patient.where(facility: facilities).where('updated_at >= ?', since)

    sync_service = SyncService.new(host, user_id, access_token)
    sync_service.sync('prescription_drugs', patients, SyncPrescriptionDrugPayload)
  end
end