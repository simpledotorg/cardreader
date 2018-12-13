require "rails_helper"

RSpec.feature "Users", type: :feature do
  let!(:admin) { create(:user, role: :admin) }
  let!(:operator) { create(:user, role: :operator) }

  context "as a non-admin" do
    before do
      sign_in(operator)
    end

    it "should not show the Users menu" do
      visit root_path

      expect(page).not_to have_link("Users")
    end
  end

  context "as an admin" do
    before do
      sign_in(admin)
    end

    it "Can list users" do
      visit users_path

      within("tr", text: admin.email) do
        expect(page).to have_content("Admin")
      end

      within("tr", text: operator.email) do
        expect(page).to have_content("Operator")
      end
    end

    it "Can edit a specific user" do
      visit users_path

      click_link operator.email

      fill_in "Email", with: "updated@example.com"
      select "Admin", from: "Role"

      click_button "Update User"

      expect(current_path).to eq(users_path)
      expect(page).to have_content("updated@example.com")
    end

    it "Can invite a new user" do
      visit users_path

      click_link "Invite user"

      fill_in "Email", with: "newuser@example.com"
      select "Operator", from: "Role"

      click_button "Send an invitation"

      expect(current_path).to eq(users_path)

      within("tr", text: "newuser@example.com") do
        expect(page).to have_content("Invitation sent")
      end
    end

    it "Can accept a user invitation" do
      user = User.invite!(email: "fake@example.com", role: :operator) do |u|
        u.skip_invitation = true
      end

      sign_out :user

      visit accept_user_invitation_url(invitation_token: user.raw_invitation_token)

      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"

      click_button "Set my password"

      expect(current_path).to eq(root_path)
    end

    it "Can delete a user" do
      visit users_path

      within("tr", text: operator.email) do
        click_link "Delete"
      end

      expect(current_path).to eq(users_path)
      expect(page).not_to have_content(operator.email)
    end
  end
end
