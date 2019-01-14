module SimpleServerSyncable
  extend ActiveSupport::Concern
  included do
    SIMPLE_SERVER_HOST = ENV.fetch('SIMPLE_SERVER_HOST')
    SIMPLE_SERVER_USER_ID = ENV.fetch('SIMPLE_SERVER_USER_ID')
    SIMPLE_SERVER_ACCESS_TOKEN = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')

    def sync_patients_for_facility(patients, facility)
      sync_service = SyncService.new(
        SIMPLE_SERVER_HOST,
        SIMPLE_SERVER_USER_ID,
        SIMPLE_SERVER_ACCESS_TOKEN,
        facility.simple_uuid
      )
      sync_service.sync_all(patients)
    end
  end
end
