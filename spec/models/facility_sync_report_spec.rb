require 'rails_helper'

RSpec.describe FacilitySyncReport, type: :model do
  describe '#last_synced_at' do
    it 'shows time for when the last time any patient in the facility was successfully synced' do
      facility = create(:facility, district: create(:district))
      old_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: old_patient.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      latest_sync_log = create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.last_synced_at).to eq(latest_sync_log.synced_at.to_formatted_s(:long))
    end
  end

  describe '#synced_patients' do
    it 'shows all synced patients for the facility' do
      facility = create(:facility, district: create(:district))
      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)
      patient_2 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_2.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.synced_patients).to eq(1)
    end
  end

  describe '#unsynced_patients' do
    it 'shows all unsynced patients for the facility' do
      facility = create(:facility, district: create(:district))
      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)
      patient_2 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_2.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.unsynced_patients).to eq(0)
    end
  end

  describe '#errored_patients' do
    it 'shows all errored patients for the facility' do
      facility = create(:facility, district: create(:district))
      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)
      patient_2 = create(:patient, facility: facility)
      create(:sync_log, simple_id: patient_2.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: latest_patient.patient_uuid)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.errored_patients).to eq(1)
    end
  end
end
