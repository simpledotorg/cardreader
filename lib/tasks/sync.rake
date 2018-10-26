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
  task :sync_patients, [:last_updated_since, :simple_uuid] => :environment do |_t, args|
    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')
    last_updated_since = args[:last_updated_since]
    simple_uuid = args[:simple_uuid]

    puts "last_updated_since not set, syncing data from beginning" unless last_updated_since.present?
    puts "simple_uuid not set, syncing data for all facilities" unless simple_uuid.present?

    since = last_updated_since.present? ? last_updated_since.to_time : Time.new(0)
    facilities = simple_uuid.present? ? Facility.where(simple_uuid: simple_uuid) : Facility.all

    patients = Patient.where(facility: facilities).where('updated_at >= ?', since)
    visits = Visit.where(patient: patients).where('updated_at >= ?', since)

    sync_service = SyncService.new(host, user_id, access_token)
    sync_service.sync('patients', patients, SyncPatientPayload)
    sync_service.sync('blood_pressures', visits, SyncBloodPressurePayload)
    sync_service.sync('medical_histories', patients, SyncMedicalHistoryPayload)
    sync_service.sync('appointments', patients, SyncAppointmentPayload)
    sync_service.sync('prescription_drugs', patients, SyncPrescriptionDrugPayload)
  end
end