require "rails_helper"

RSpec.describe DistrictPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:operator) { create(:user, :operator) }

  permissions :index?, :show? do
    it "permits admins" do
      expect(subject).to permit(admin, District)
    end

    it "permits operators" do
      expect(subject).to permit(operator, District)
    end
  end

  permissions :new?, :create?, :update?, :edit?, :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, District)
    end

    it "denies operators" do
      expect(subject).not_to permit(operator, District)
    end
  end

  permissions :import? do
    it "permits admins" do
      expect(subject).to permit(admin, District)
    end
  end
end
