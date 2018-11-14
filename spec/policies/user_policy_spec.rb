require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:owner) { create(:user, :admin) }
  let(:operator) { create(:user, :operator) }

  permissions :index?, :show?, :new?, :create?, :update?, :edit?, :destroy? do
    it "permits owners" do
      expect(subject).to permit(owner, User)
    end

    it "denies operators" do
      expect(subject).not_to permit(operator, User)
    end
  end
end
