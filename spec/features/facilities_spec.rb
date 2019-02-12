require 'rails_helper'

RSpec.feature "Facilities", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }

  let(:admin) { create(:user, :admin) }

  before do
    sign_in(admin)
  end

  describe "show" do
    let!(:patient_1) { create(:patient, facility: facility) }
    let!(:patient_2) { create(:patient, facility: facility) }
    let!(:other_patient) { create(:patient, facility: build(:facility)) }

    before do
      visit root_path
      click_link district.name
      click_link facility.name
    end

    it "shows all treatment cards in the facility" do
      expect(page).to have_link(patient_1.formatted_treatment_number)
      expect(page).to have_link(patient_2.formatted_treatment_number)
    end

    it "does not show treatment cards from another facility" do
      expect(page).not_to have_link(other_patient.formatted_treatment_number)
    end
  end

  describe "new" do
    describe "adding a facility" do
      before do
        visit new_district_facility_path(district)
      end

      it "displays the new facility" do
        fill_in "Facility name", with: "PHC Paldi"
        click_button "Add"

        expect(page).to have_link("PHC Paldi")

        new_facility = Facility.find_by(name: "PHC Paldi")
        expect(new_facility.district).to eq(district)
        expect(new_facility.author).to eq(admin)
      end

      it "shows the correct error if name is blank" do
        click_button "Add"
        expect(page).to have_content("Facility name can't be blank")
      end
    end
  end
end
