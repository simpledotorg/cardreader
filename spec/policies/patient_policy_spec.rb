require "rails_helper"

RSpec.describe PatientPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:operator) { create(:user, :operator) }

  permissions :index?, :show?, :new?, :create?, :update?, :edit?, :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, Patient)
    end

    it "permits operators" do
      expect(subject).to permit(operator, Patient)
    end
  end
end
