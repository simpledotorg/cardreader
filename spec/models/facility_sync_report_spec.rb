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

      expect(sync_report.synced).to eq(1)
    end
  end

  describe '#unsynced' do
    it 'shows all unsynced patients for the facility' do
      facility = create(:facility, district: create(:district))
      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)
      patient_2 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_2.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.unsynced).to eq(0)
    end
  end

  describe '#errored' do
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

      expect(sync_report.errored).to eq(1)
    end
  end

  describe '#highest_treatment_number' do
    it 'shows the patient with the highest treatment number value' do
      facility = create(:facility, district: create(:district))
      create(:patient, facility: facility, treatment_number: '2018-00000701')
      create(:patient, facility: facility, treatment_number: '2019-00000702')
      create(:patient, facility: facility, treatment_number: '2018-00000171')

      sync_report = FacilitySyncReport.new(facility)

      expect(sync_report.highest_treatment_number).to eq('2019-00000702')
    end
  end
end
