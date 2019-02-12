require 'rails_helper'

RSpec.describe Patient, type: :model do
  subject(:patient) { build(:patient) }

  describe "Associations" do
    it { should belong_to(:author).class_name("User").with_foreign_key("author_id") }
    it { should belong_to(:facility) }
    it { should have_many(:visits).inverse_of(:patient).dependent(:destroy) }

    it { should validate_presence_of(:treatment_number) }
    it {
      should validate_uniqueness_of(:treatment_number)
                       .scoped_to(:facility_id)
                       .case_insensitive
                       .with_message("should be unique per facility")
    }
  end

  describe "#formatted_treatment_number=" do
    it "works with empty treatment numbers" do
      patient.treatment_number = nil
      expect(patient.formatted_treatment_number).to eq("2018-00000000")
    end

    it "adds leading zeroes" do
      patient.treatment_number = 1234
      expect(patient.formatted_treatment_number).to eq("2018-00001234")
    end

    it "doesn't add too many leading zeroes" do
      patient.treatment_number = 123456789
      expect(patient.formatted_treatment_number).to eq("2018-123456789")
    end

    it "does not format non-integers" do
      patient.treatment_number = "2018-00005555"
      expect(patient.formatted_treatment_number).to eq("2018-00005555")
    end
  end

  describe "#treatment_number_prefix" do
    it "works with empty treatment numbers" do
      patient.treatment_number = nil
      expect(patient.treatment_number_prefix).to eq("2018-00000000")
    end

    it "adds leading zeroes" do
      patient.treatment_number = 1234
      expect(patient.treatment_number_prefix).to eq("2018-0000")
    end

    it "doesn't add too many leading zeroes" do
      patient.treatment_number = 123456789
      expect(patient.treatment_number_prefix).to eq("2018-")
    end

    it "does not format non-integers" do
      patient.treatment_number = "2018-00005555"
      expect(patient.treatment_number_prefix).to eq("")
    end
  end

  describe '.last_synced_at' do
    it 'shows time for when the last time any patient in the facility was successfully synced' do

      facility = create(:facility, district: create(:district))
      old_patient = create(:patient, facility: facility)
      create(:sync_log, simple_id: old_patient.patient_uuid)
      latest_patient = create(:patient, facility: facility)
      latest_sync_log = create(:sync_log, simple_id: latest_patient.patient_uuid)

      expect(Patient.last_synced_at.to_i).to eq(latest_sync_log.synced_at.to_i)
    end

    it 'returns nil if there are no sync logs' do
      facility = create(:facility, district: create(:district))
      create(:patient, facility: facility)
      create(:patient, facility: facility)

      expect(Patient.last_synced_at).to be_nil
    end

    it 'returns nil if there are no patients' do
      expect(Patient.last_synced_at).to be_nil
    end
  end

  describe '.highest_treatment_number' do
    it 'shows the patient with the highest treatment number value' do
      facility = create(:facility, district: create(:district))
      create(:patient, facility: facility, treatment_number: '2018-00000701')
      create(:patient, facility: facility, treatment_number: '2019-00000702')
      create(:patient, facility: facility, treatment_number: '2018-00000171')

      expect(Patient.highest_treatment_number).to eq('2019-00000702')
    end

    it 'returns nil if there are no patients' do
      expect(Patient.highest_treatment_number).to be_nil
    end
  end
end
