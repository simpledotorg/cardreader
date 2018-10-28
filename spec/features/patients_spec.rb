require 'rails_helper'

RSpec.feature "Patients", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }
  let!(:patient) { create(:patient, facility: facility) }
  let!(:visits) { create_list(:visit, 3, patient: patient) }

  before do
    visit district_facility_path(district, facility)
  end

  describe "show" do
    before do
      click_link patient.formatted_treatment_number
    end

    it "shows patient details" do
      expect(page).to have_content("Treatment Number #{patient.formatted_treatment_number}")
      expect(page).to have_content(patient.name)
    end

    it "shows blood pressures" do
      patient.visits.each do |bp|
        expect(page).to have_content("#{bp.systolic} / #{bp.diastolic}")
      end
    end
  end

  describe "new" do
    before do
      click_link "Add Treatment Card"

      fill_in "Date of registration", with: "25/12/2018"
      fill_in "Treatment number", with: "1234"
      fill_in "Full name", with: "Deepa Singh"
      choose "Female"
      fill_in "Age", with: "36"
      fill_in "House number", with: "555"
      fill_in "Street name", with: "Test Road"
      fill_in "Area/Colony", with: "Test Area"
      fill_in "Village/Town", with: "Test Village"
      fill_in "District name", with: "Test District"
      fill_in "Pincode", with: "Test Pin"
      fill_in "Patient phone", with: "1122334455"
      fill_in "Alternate phone", with: "9988776655"

      check "Hypertension. Yes, treatment initiated."
      check "Yes, was already on treatment when registered."

      find(".form-row", text: "Prior heart attack").choose("Yes")
      find(".form-row", text: "Heart attack in last 3 years").choose("Yes")
      find(".form-row", text: "Prior stroke").choose("Yes")
      find(".form-row", text: "Chronic kidney disease").choose("Yes")

      fill_in :patient_medication1_name, with: "Test med 1"
      fill_in :patient_medication1_dose, with: "10mg"
      fill_in :patient_medication2_name, with: "Test med 2"
      fill_in :patient_medication2_dose, with: "20mg"
      fill_in :patient_medication3_name, with: "Test med 3"
      fill_in :patient_medication3_dose, with: "30mg"
      fill_in :patient_medication4_name, with: "Test med 4"
      fill_in :patient_medication4_dose, with: "40mg"
    end

    it "saves the patient data", aggregate_failures: true do
      click_button "Save Treatment Card"

      new_patient = Patient.order(:created_at).last

      expect(new_patient.registered_on).to eq(Date.parse("25/12/2018"))
      expect(new_patient.treatment_number).to eq("1234")
      expect(new_patient.name).to eq("Deepa Singh")
      expect(new_patient.gender).to eq("Female")
      expect(new_patient.age).to eq(36)
      expect(new_patient.house_number).to eq("555")
      expect(new_patient.street_name).to eq("Test Road")
      expect(new_patient.area).to eq("Test Area")
      expect(new_patient.village).to eq("Test Village")
      expect(new_patient.district).to eq("Test District")
      expect(new_patient.pincode).to eq("Test Pin")
      expect(new_patient.phone).to eq("1122334455")
      expect(new_patient.alternate_phone).to eq("9988776655")

      expect(new_patient.already_on_treatment).to eq(true)
      expect(new_patient.prior_heart_attack).to eq(true)
      expect(new_patient.heart_attack_in_last_3_years).to eq(true)
      expect(new_patient.prior_stroke).to eq(true)
      expect(new_patient.chronic_kidney_disease).to eq(true)
      expect(new_patient.diagnosed_with_hypertension).to eq(true)

      expect(new_patient.medication1_name).to eq("Test med 1")
      expect(new_patient.medication1_dose).to eq("10mg")
      expect(new_patient.medication2_name).to eq("Test med 2")
      expect(new_patient.medication2_dose).to eq("20mg")
      expect(new_patient.medication3_name).to eq("Test med 3")
      expect(new_patient.medication3_dose).to eq("30mg")
      expect(new_patient.medication4_name).to eq("Test med 4")
      expect(new_patient.medication4_dose).to eq("40mg")
    end
  end

  describe "edit" do
    before do
      click_link patient.formatted_treatment_number
      click_link "Edit Patient"
    end

    it "saves changes" do
      fill_in "Full name", with: "New Name"
      click_button("Save Treatment Card")
      expect(page).to have_content("New Name")
    end
  end

  describe "delete" do
    before do
      click_link patient.formatted_treatment_number
      click_link "Delete Patient"
    end

    it "deletes the patient" do
      expect(page).not_to have_content(patient.formatted_treatment_number)
    end
  end
end
