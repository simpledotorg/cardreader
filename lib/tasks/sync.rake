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
  task sync_patients: :environment do
    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')
    # SyncPatientService.new(host, user_id, access_token).sync
    # SyncBloodPressureService.new(host, user_id, access_token).sync
    # SyncAppointmentService.new(host, user_id, access_token).sync
    SyncMedicalHistoryService.new(host, user_id, access_token).sync
  end
end