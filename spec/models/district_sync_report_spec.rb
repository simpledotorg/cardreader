require 'rails_helper'

RSpec.describe DistrictSyncReport, type: :model do
  describe '#last_synced_at' do
    it 'shows time for when the last time any facility was synced' do
      district = create(:district)
      facility_1 = create(:facility, district: district)
      facility_2 = create(:facility, district: district)

      p1 = create(:patient, facility: facility_1)
      p2 = create(:patient, facility: facility_2)
      p3 = create(:patient, facility: facility_2)

      latest_sync_time = Time.now.utc + 1.day
      create(:sync_log, simple_id: p1.patient_uuid, synced_at: Time.now.utc)
      create(:sync_log, simple_id: p2.patient_uuid, synced_at: latest_sync_time)
      create(:sync_log, simple_id: p3.patient_uuid, synced_at: Time.now.utc - 1.day)

      sync_report = DistrictSyncReport.new(district)

      expect(sync_report.last_synced_at).to eq(latest_sync_time.to_formatted_s(:long))
    end
  end
end
