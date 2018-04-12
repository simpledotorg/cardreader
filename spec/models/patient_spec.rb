require 'rails_helper'

RSpec.describe Patient, type: :model do
  subject(:patient) { build(:patient) }

  describe "#treatment_number=" do
    it "re-formats short integers" do
      patient.treatment_number = 1234
      expect(patient.treatment_number).to eq("2018-00001234")
    end

    it "re-formats long integers" do
      patient.treatment_number = 12345678
      expect(patient.treatment_number).to eq("2018-12345678")
    end

    it "does not format non-integers" do
      patient.treatment_number = "2018-00005555"
      expect(patient.treatment_number).to eq("2018-00005555")
    end
  end
end
