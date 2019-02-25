class SyncAppointmentPayload
  attr_reader :patient

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_payload
    visits = patient.visits
    return [] unless visits.present?

    visits_by_measurement_date = visits.order(:measured_on)
    appointments = visits_by_measurement_date[0..-2].map { |visit| appointment_payload(visit) }.compact

    latest_visit = visits_by_measurement_date.last
    if latest_visit.next_visit_on.present?
      latest_appointment = appointment_payload(latest_visit)
      latest_appointment[:status] = 'scheduled'
      appointments << latest_appointment
    end

    appointments
  end

  private

  def appointment_payload(visit)
    return nil if visit.next_visit_on.blank?

    {id: visit.appointment_uuid,
     patient_id: visit.patient.patient_uuid,
     facility_id: visit.facility.simple_uuid,
     scheduled_date: visit.next_visit_on,
     status: 'visited',
     created_at: visit.measured_on_without_timestamp,
     updated_at: visit.measured_on_without_timestamp, }
  end
end