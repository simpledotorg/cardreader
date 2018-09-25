require 'rails_helper'

RSpec.feature "Patients", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }

  describe "show" do
    let!(:patient) { create(:patient, facility: facility) }
    let!(:blood_pressures) { create_list(:blood_pressure, 3, patient: patient) }

    before do
      visit district_facility_path(district, facility)
      click_link patient.treatment_number
    end

    it "shows patient details" do
      expect(page).to have_content("Treatment Number #{patient.treatment_number}")
      expect(page).to have_content(patient.name)
    end

    it "shows blood pressures" do
      patient.blood_pressures.each do |bp|
        expect(page).to have_content("#{bp.systolic} / #{bp.diastolic}")
      end
    end
  end

  describe "edit" do
    let!(:patient) { create(:patient, facility: facility) }
    let!(:blood_pressures) { create_list(:blood_pressure, 3, patient: patient) }

    before do
      visit district_facility_path(district, facility)
      click_link patient.treatment_number
      click_link "Edit Patient"
    end

    it "saves changes" do
      fill_in "Name", with: "New Name"
      click_button("Save Treatment Card")
      expect(page).to have_content("New Name")
    end
  end
end
