class SyncAppointmentPayload
  attr_reader :patient

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_payload
    visits = patient.visits
    return [] unless visits.present?
    requests = visits.map { |visit| appointment_payload(visit) }.compact
    requests.last[:status] = 'scheduled' if requests.present?
    requests
  end

  private

  def appointment_payload(visit)
    return nil if visit.next_visit_on.blank?
    { id: visit.appointment_uuid,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.simple_uuid,
      scheduled_date: visit.next_visit_on,
      status: 'visited',
      created_at: visit.measured_on_without_timestamp,
      updated_at: visit.measured_on_without_timestamp,}
  end
end