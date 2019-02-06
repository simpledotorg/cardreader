require 'rails_helper'

RSpec.feature "Facilities", type: :feature do
  let!(:district) { create(:district, name: "Mansa") }
  let!(:facility) { create(:facility, district: district, name: "District Hospital") }

  before do
    sign_in(create(:user, :admin))
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

    context "treatments cards" do
      it "show all in the facility" do
        expect(page).to have_link(patient_1.formatted_treatment_number)
        expect(page).to have_link(patient_2.formatted_treatment_number)
      end

      it "does not show any from another facility" do
        expect(page).not_to have_link(other_patient.formatted_treatment_number)
      end
    end

    context "facility sync" do
      it "does not allow syncing patients for facility when all patients are already synced" do
        create(:sync_log, simple_id: patient_1.patient_uuid)
        create(:sync_log, simple_id: patient_2.patient_uuid)

        visit current_path

        expect(page).not_to have_link(href: district_facility_sync_path(district.id, facility.id))
      end

      it "allows syncing patients for facility if any patient was updated" do
        patient_with_sync_errors = create(:patient, facility: facility)
        create(:sync_log, :with_sync_errors, simple_id: patient_with_sync_errors.patient_uuid)

        patient_with_sync_errors.update(updated_at: Time.now)
        visit current_path

        expect(page).to have_link(href: district_facility_sync_path(district.id, facility.id))
      end

      it "allows syncing patients for facility if any patient is not synced" do
        expect(page).to have_link(href: district_facility_sync_path(district.id, facility.id))
      end
    end
  end
end
