require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:operator) { create(:user, :operator) }

  permissions :index?, :show?, :new?, :create?, :update?, :edit?, :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, User)
    end

    it "denies operators" do
      expect(subject).not_to permit(operator, User)
    end
  end
end
