require 'rails_helper'

RSpec.feature "Patients", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }
  let!(:patient) { create(:patient, facility: facility) }
  let!(:visits) { create_list(:visit, 3, patient: patient) }

  before do
    visit district_facility_path(district, facility)
    click_link patient.treatment_number
  end

  describe "show" do
    it "shows patient details" do
      expect(page).to have_content("Treatment Number #{patient.treatment_number}")
      expect(page).to have_content(patient.name)
    end

    it "shows blood pressures" do
      patient.visits.each do |bp|
        expect(page).to have_content("#{bp.systolic} / #{bp.diastolic}")
      end
    end
  end

  describe "edit" do
    before do
      click_link "Edit Patient"
    end

    it "saves changes" do
      fill_in "Name", with: "New Name"
      click_button("Save Treatment Card")
      expect(page).to have_content("New Name")
    end
  end

  describe "delete" do
    before do
      click_link "Delete Patient"
    end

    it "deletes the patient" do
      expect(page).not_to have_content(patient.treatment_number)
    end
  end
end
