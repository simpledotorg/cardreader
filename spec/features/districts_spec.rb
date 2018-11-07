require 'rails_helper'

RSpec.feature "Districts", type: :feature do
  let!(:bathinda) { create(:district, name: "Bathinda") }
  let!(:mansa) { create(:district, name: "Mansa") }

  before do
    sign_in(create(:user, :admin))
  end

  describe "index" do
    before do
      visit root_path
    end

    it "shows all districts" do
      expect(page).to have_link(bathinda.name)
      expect(page).to have_link(mansa.name)
    end
  end

  describe "show" do
    let!(:mansa_hospital) { create(:facility, district: mansa, name: "District Hospital") }
    let!(:mansa_phc) { create(:facility, district: mansa, name: "PHC Joga") }
    let!(:bathinda_chc) { create(:facility, district: bathinda, name: "CHC Bhagta") }

    before do
      visit root_path
      click_link mansa.name
    end

    it "shows all facilities in the district" do
      expect(page).to have_link(mansa_hospital.name)
      expect(page).to have_link(mansa_phc.name)
    end

    it "does not show facilities from other districts" do
      expect(page).not_to have_link(bathinda_chc.name)
    end

    describe "adding a facility" do
      it "displays the new facility" do
        fill_in "Facility name", with: "PHC Paldi"
        click_button "Add Facility"

        expect(page).to have_link("PHC Paldi")
      end

      it "shows the correct error if name is blank" do
        click_button "Add Facility"
        expect(page).to have_content("Facility name can't be blank")
      end
    end
  end
end
