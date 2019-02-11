require 'rails_helper'

RSpec.describe SyncReport, type: :model do
  describe '#synced' do
    it 'shows all synced patients for the facility' do
      facility = create(:facility, district: create(:district))

      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)

      patient_2 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_2.patient_uuid)

      latest_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.synced).to eq(1)
    end
  end

  describe '#synced_percentage' do
    it 'shows the synced percentage for the facility' do
      facility = create(:facility, district: create(:district))

      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)

      patient_2 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_2.patient_uuid)

      latest_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: latest_patient.patient_uuid)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.synced_percentage).to eq(33.333333333333336)
    end

    it 'is zero when there are no sync records' do
      facility = create(:facility, district: create(:district))

      create(:patient, facility: facility)
      create(:patient, facility: facility)
      create(:patient, facility: facility)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.synced_percentage).to eq(0.0)
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

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.unsynced).to eq(0)
    end
  end

  describe '#usynced_percentage' do
    it 'shows the unsynced percentage for the facility' do
      facility = create(:facility, district: create(:district))

      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)

      create(:patient, facility: facility)
      create(:patient, facility: facility)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.unsynced_percentage).to eq(66.66666666666667)
    end

    it 'is 100% when there are no sync records' do
      facility = create(:facility, district: create(:district))

      create(:patient, facility: facility)
      create(:patient, facility: facility)
      create(:patient, facility: facility)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.unsynced_percentage).to eq(100.0)
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

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.errored).to eq(1)
    end
  end

  describe '#errored_percentage' do
    it 'shows the unsynced percentage for the facility' do
      facility = create(:facility, district: create(:district))

      patient_1 = create(:patient, facility: facility)
      create(:sync_log, :with_sync_errors, simple_id: patient_1.patient_uuid)

      create(:patient, facility: facility)
      create(:patient, facility: facility)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.sync_error_percentage).to eq(33.333333333333336)
    end

    it 'is zero when there are no sync records' do
      facility = create(:facility, district: create(:district))

      create(:patient, facility: facility)
      create(:patient, facility: facility)
      create(:patient, facility: facility)

      sync_report = SyncReport.new(facility.patients.sync_statuses)

      expect(sync_report.sync_error_percentage).to eq(0.0)
    end
  end
end
