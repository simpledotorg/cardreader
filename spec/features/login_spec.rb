require 'rails_helper'

RSpec.feature 'Admin::Login', type: :feature do
  let(:user) { create(:user) }

  it 'Log in and see dashboard by default' do
    visit root_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    click_button 'Login'

    expect(page).to have_content('Logout')
  end

  it 'Log out and go back to login screen' do
    sign_in(user)
    visit districts_path

    click_link 'Logout'

    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content('Login')
  end
end
