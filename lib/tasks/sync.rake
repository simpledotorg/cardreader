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
      patients_to_sync = Patient.where(facility: facility).select(&:unsynced?)
      visits_to_sync = Visit.where(patient: patients_to_sync).select(&:unsynced?)

      sync_service = SyncService.new(host, user_id, access_token, facility.simple_uuid)
      sync_service.sync('patients', patients_to_sync, SyncPatientPayload, report_errors_on_class: Patient)
      sync_service.sync('blood_pressures', visits_to_sync, SyncBloodPressurePayload, report_errors_on_class: Visit)
      sync_service.sync('medical_histories', patients_to_sync, SyncMedicalHistoryPayload, report_errors_on_class: Patient)
      sync_service.sync('appointments', patients_to_sync, SyncAppointmentPayload, report_errors_on_class: Visit)
      sync_service.sync('prescription_drugs', patients_to_sync, SyncPrescriptionDrugPayload)
    end
  end
end