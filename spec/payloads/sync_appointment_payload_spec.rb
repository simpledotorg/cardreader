require 'rails_helper'

RSpec.describe SyncAppointmentPayload do
  let!(:district) { create(:district, name: "Test District") }
  let!(:facility) { create(:facility, district: district, name: "Test Facility") }
  let!(:patient) { create(:patient, facility: facility) }

  let!(:user) { create(:user, :admin) }
  let!(:appointment_payload) { SyncAppointmentPayload.new(patient, user.id) }
  let!(:visits) { create_list(:visit, 3, patient: patient) }

  context "when all the visits have a 'next_visit_on' field" do
    it "should mark all visits except the last one as 'visited'" do
      sync_payload = appointment_payload.to_payload

      expect(sync_payload[0][:status]).to eq 'visited'
      expect(sync_payload[1][:status]).to eq 'visited'
    end

    it "should mark the last visit as 'scheduled'" do
      sync_payload = appointment_payload.to_payload

      expect(sync_payload[2][:status]).to eq 'scheduled'
    end

    it 'should have all the visits as part of sync payload' do
      sync_payload = appointment_payload.to_payload

      expect(sync_payload.count).to be 3
    end
  end

  context "when all but the last visit have a 'next_visit_on' field" do
    it "should mark all but the last visit as 'visited'" do
      visits[2].next_visit_on = nil
      visits[2].measured_on = 3.months.from_now
      visits[2].save

      sync_payload = appointment_payload.to_payload
      expect(sync_payload[0][:status]).to eq 'visited'
      expect(sync_payload[1][:status]).to eq 'visited'
    end

    it "should not have the last visit as part of the sync payload" do
      visits[2].next_visit_on = nil
      visits[2].measured_on = 3.months.from_now
      visits[2].save

      sync_payload = appointment_payload.to_payload

      expect(sync_payload.count).to be 2
    end
  end
end