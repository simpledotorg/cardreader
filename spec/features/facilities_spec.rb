require 'rails_helper'

RSpec.feature "Facilities", type: :feature do
  let!(:mansa) { create(:district, name: "Mansa") }

  let!(:facility) { create(:facility, district: mansa, name: "District Hospital") }

  describe "show" do
    let!(:patient_1) { create(:patient, facility: facility) }
    let!(:patient_2) { create(:patient, facility: facility) }
    let!(:other_patient) { create(:patient, facility: build(:facility)) }

    before do
      visit root_path
      click_link mansa.name
      click_link facility.name
    end

    it "shows all treatment cards in the facility" do
      expect(page).to have_link(patient_1.treatment_number)
      expect(page).to have_link(patient_2.treatment_number)
    end

    it "does not show treatment cards from another facility" do
      expect(page).not_to have_link(other_patient.treatment_number)
    end
  end
end
