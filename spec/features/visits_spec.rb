require 'rails_helper'

RSpec.feature "Visits", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }
  let!(:patient) { create(:patient, facility: facility) }

  describe "new" do
    before do
      visit district_facility_patient_path(district, facility, patient)
      click_link "Add Visit Details"
    end

    it "saves a new visit" do
      fill_in "Date attended", with: "2018-02-01"
      fill_in "Systolic", with: 145
      fill_in "Diastolic", with: 95
      fill_in "Amlodipine", with: "10mg"
      click_button "Create Visit"

      expect(page).to have_content("145 / 95")
      expect(page).to have_content("Amlodipine: 10mg")
    end
  end

  describe "edit" do
    let!(:patient) { create(:patient, facility: facility) }
    let!(:visits) { create_list(:visit, 3, patient: patient) }

    before do
      visit district_facility_patient_path(district, facility, patient)

      within find("tr", text: "#{visits.first.systolic} / #{visits.first.diastolic}") do
        click_link "Edit"
      end
    end

    it "saves changes" do
      fill_in "Systolic", with: 145
      fill_in "Diastolic", with: 95
      fill_in "Amlodipine", with: "20mg"
      fill_in "Telmisartan", with: "90mg"
      click_button("Update Visit")

      within find("tr", text: "145 / 95") do
        expect(page).to have_content("Amlodipine: 20mg")
        expect(page).to have_content("Telmisartan: 90mg")
      end
    end
  end
end
