require 'rails_helper'

RSpec.feature "Visits", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }
  let!(:patient) { create(:patient, facility: facility) }
  let!(:visits) { create_list(:visit, 3, patient: patient) }

  before do
    sign_in(create(:user, :admin))
    visit district_facility_patient_path(district, facility, patient)
  end

  describe "new" do
    before do
      click_link "Add Visit Details"

      fill_in "Date attended", with: "01/11/2018"
      fill_in "Systolic", with: "145"
      fill_in "Diastolic", with: "95"
      fill_in "Blood sugar", with: "100"

      fill_in "Amlodipine dose", with: "10mg"
      fill_in "Telmisartan dose", with: "20mg"
      fill_in "Enalpril dose", with: "30mg"
      fill_in "Chlorthalidone dose", with: "40mg"
      fill_in "Aspirin dose", with: "50mg"
      fill_in "Statin dose", with: "60mg"
      fill_in "Beta blocker dose", with: "70mg"

      fill_in "visit_medication1_name", with: "Test med 1"
      fill_in "visit_medication1_dose", with: "100mg"
      fill_in "visit_medication2_name", with: "Test med 2"
      fill_in "visit_medication2_dose", with: "200mg"
      fill_in "visit_medication3_name", with: "Test med 3"
      fill_in "visit_medication3_dose", with: "300mg"

      fill_in "Next visit date", with: "01/12/2018"
      check "Referred to specialist"
    end

    it "shows a summary of the saved visit data" do
      click_button "Save"

      expect(page).to have_content("145 / 95")
      expect(page).to have_content("Amlodipine: 10mg")
      expect(page).to have_content("Test med 1: 100mg")
    end

    it "saves the visit data" do
      click_button "Save"

      visit = Visit.order(:created_at).last

      expect(visit.measured_on).to eq(Date.parse("2018-11-01"))
      expect(visit.systolic).to eq(145)
      expect(visit.diastolic).to eq(95)
      expect(visit.blood_sugar).to eq("100")

      expect(visit.amlodipine).to eq("10mg")
      expect(visit.telmisartan).to eq("20mg")
      expect(visit.enalpril).to eq("30mg")
      expect(visit.chlorthalidone).to eq("40mg")
      expect(visit.aspirin).to eq("50mg")
      expect(visit.statin).to eq("60mg")
      expect(visit.beta_blocker).to eq("70mg")

      expect(visit.medication1_name).to eq("Test med 1")
      expect(visit.medication1_dose).to eq("100mg")
      expect(visit.medication2_name).to eq("Test med 2")
      expect(visit.medication2_dose).to eq("200mg")
      expect(visit.medication3_name).to eq("Test med 3")
      expect(visit.medication3_dose).to eq("300mg")

      expect(visit.next_visit_on).to eq(Date.parse("2018-12-01"))
      expect(visit.referred_to_specialist).to eq(true)
    end
  end

  describe "edit" do
    before do
      within find("tr", text: "#{visits.first.systolic} / #{visits.first.diastolic}") do
        click_link "Edit"
      end
    end

    it "saves changes" do
      fill_in "Systolic", with: 145
      fill_in "Diastolic", with: 95
      fill_in "Amlodipine", with: "20mg"
      fill_in "Telmisartan", with: "90mg"
      click_button("Save")

      within find("tr", text: "145 / 95") do
        expect(page).to have_content("Amlodipine: 20mg")
        expect(page).to have_content("Telmisartan: 90mg")
      end
    end
  end

  describe "delete" do
    before do
      within find("tr", text: "#{visits.first.systolic} / #{visits.first.diastolic}") do
        click_link "Edit"
      end

      click_link "Delete Visit"
    end

    it "deletes the visit" do
      expect(page).not_to have_content("#{visits.first.systolic} / #{visits.first.diastolic}")
    end
  end
end
