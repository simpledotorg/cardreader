require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:facilities) }
    it { should have_many(:patients) }
    it { should have_many(:visits) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:password)}
    it { should validate_presence_of(:role) }

    it { should define_enum_for(:role).with([:admin, :operator]) }
  end
end
