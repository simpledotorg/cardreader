class SyncAppointmentPayload
  attr_reader :patient
  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_request
    visits = patient.visits
    return [] unless visits.present?
    requests = visits.map { |visit| appointment_request(visit) }.reject(&:nil?)
    requests.last[:status] = 'scheduled' if requests.present?
    requests
  end

  private

  def device_created_at(visit)
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def appointment_request(visit)
    return nil if visit.next_visit_on.blank?
    { id: visit.appointment_uuid,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.try(:simple_uuid),
      scheduled_date: visit.next_visit_on,
      status: 'visited',
      created_at: device_created_at(visit),
      updated_at: Time.now }
  end
end
class SyncAppointmentRequest
  attr_reader :patient
  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_request
    visits = patient.visits
    return [] unless visits.present?
    requests = visits.map { |visit| appointment_request(visit) }.reject(&:nil?)
    requests.last[:status] = 'scheduled' if requests.present?
    requests
  end

  private

  def device_created_at(visit)
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def appointment_request(visit)
    return nil if visit.next_visit_on.blank?
    { id: visit.appointment_uuid,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.try(:simple_uuid),
      scheduled_date: visit.next_visit_on,
      status: 'visited',
      created_at: device_created_at(visit),
      updated_at: Time.now }
  end
end