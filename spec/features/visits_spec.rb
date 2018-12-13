require 'rails_helper'

RSpec.feature "Visits", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }
  let!(:patient) { create(:patient, facility: facility) }
  let!(:visits) { create_list(:visit, 3, patient: patient) }

  let(:user) { create(:user, :operator) }

  before do
    sign_in(user)
    visit district_facility_patient_path(district, facility, patient)
  end

  describe "new" do
    before do
      click_link "Add Visit"

      fill_in "Date attended", with: "25/11/2018"
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

      fill_in "Next visit date", with: "25/12/2018"
      check "Referred to specialist"
    end

    it "shows a summary of the saved visit data" do
      click_button "Save"

      expect(page).to have_selector(".visit-systolic", text: "145")
      expect(page).to have_selector(".visit-diastolic", text: "95")
      expect(page).to have_selector(".visit-amlodipine", text: "10mg")
    end

    it "saves the visit data" do
      click_button "Save"

      new_visit = Visit.order(:created_at).last

      expect(new_visit.measured_on).to eq(Date.parse("2018-11-25"))
      expect(new_visit.systolic).to eq(145)
      expect(new_visit.diastolic).to eq(95)
      expect(new_visit.blood_sugar).to eq("100")

      expect(new_visit.amlodipine).to eq("10mg")
      expect(new_visit.telmisartan).to eq("20mg")
      expect(new_visit.enalpril).to eq("30mg")
      expect(new_visit.chlorthalidone).to eq("40mg")
      expect(new_visit.aspirin).to eq("50mg")
      expect(new_visit.statin).to eq("60mg")
      expect(new_visit.beta_blocker).to eq("70mg")

      expect(new_visit.medication1_name).to eq("Test med 1")
      expect(new_visit.medication1_dose).to eq("100mg")
      expect(new_visit.medication2_name).to eq("Test med 2")
      expect(new_visit.medication2_dose).to eq("200mg")
      expect(new_visit.medication3_name).to eq("Test med 3")
      expect(new_visit.medication3_dose).to eq("300mg")

      expect(new_visit.next_visit_on).to eq(Date.parse("2018-12-25"))
      expect(new_visit.referred_to_specialist).to eq(true)

      expect(new_visit.author).to eq(user)
    end
  end

  describe "edit" do
    before do
      within find(".visit", text: visits.first.measured_on.strftime("%d/%m/%Y")) do
        click_link "Edit"
      end
    end

    it "saves changes" do
      fill_in "Systolic", with: 195
      fill_in "Diastolic", with: 112
      fill_in "Amlodipine", with: "20mg"
      fill_in "Telmisartan", with: "90mg"
      click_button("Save")

      within find(".visit", text: visits.first.measured_on.strftime("%d/%m/%Y")) do
        expect(page).to have_selector(".visit-systolic", text: "195")
        expect(page).to have_selector(".visit-diastolic", text: "112")
        expect(page).to have_selector(".visit-amlodipine", text: "20mg")
        expect(page).to have_selector(".visit-telmisartan", text: "90mg")
      end
    end
  end

  describe "delete" do
    before do
      within find(".visit", text: visits.first.measured_on.strftime("%d/%m/%Y")) do
        click_link "Edit"
      end

      click_link "Delete Visit"
    end

    it "deletes the visit" do
      expect(page).not_to have_content("#{visits.first.systolic} / #{visits.first.diastolic}")
    end
  end
end
