require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:visit) { build(:visit) }

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:patient) }
  end

  describe "Validations" do
    it { should validate_presence_of(:measured_on) }

    describe "validating next_visit_on" do
      it "is valid if next_visit_on > meassured_on" do
        visit.measured_on = "2018-01-01"
        visit.next_visit_on = "2018-01-02"
        expect(visit).to be_valid
      end

      it "is not valid if next_visit_on == measured_on" do
        visit.measured_on = "2018-01-01"
        visit.next_visit_on = "2018-01-01"
        expect(visit).not_to be_valid
        expect(visit.errors[:next_visit_on]).to include("must be later than the date attended")
      end

      it "is not valid if next_visit_on < measured_on" do
        visit.measured_on = "2018-01-01"
        visit.next_visit_on = "2017-01-01"
        expect(visit).not_to be_valid
        expect(visit.errors[:next_visit_on]).to include("must be later than the date attended")
      end
    end
  end
end
