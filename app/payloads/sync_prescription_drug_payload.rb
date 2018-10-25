class SyncPrescriptionDrugPayload
  attr_reader :patient, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_request
    visits = patient.visits
    return [] unless visits.present?
    requests = visits.map { |visit| prescription_drug_request(visit) }.reject(&:nil?)
    requests.last.map { |drug| drug[:is_deleted] = false } if requests.present?
    requests.flatten
  end

  def uuid(uniq_hash)
    UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, uniq_hash.to_s).to_s
  end

  def protocol_drug_keys
    %w(amlodipine telmisartan chlorthalidone)
  end

  def common_drug_keys
    %w(amlodipine telmisartan enalpril chlorthalidone aspirin statin beta_blocker losartan)
  end

  def custom_drug_keys
    %w(medication1_name medication2_name medication3_name)
  end

  def custom_drug_name(drug_value)
    drug_value.match(/\b [A-z]{3,} \b/x).to_s
  end

  def custom_drug_dosage(drug_value)
    drug_value.match(/\d*\s*mg/i).to_s.downcase
  end

  def device_created_at(visit)
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def prescription_drug_request(visit)
    visit_attributes = visit.attributes.with_indifferent_access

    common_drugs = common_drug_keys.map do |key|
      if visit_attributes[key].present?
        { id: uuid({ patient_id: patient.patient_uuid, facility_id: patient.facility.simple_uuid, name: key }),
          name: key.humanize,
          dosage: visit_attributes[key] || '',
          is_deleted: true,
          patient_id: patient.patient_uuid,
          facility_id: visit.facility.simple_uuid,
          is_protocol_drug: protocol_drug_keys.include?(key),
          created_at: device_created_at(visit),
          updated_at: device_created_at(visit) }
      else
        nil
      end
    end

    custom_drugs = custom_drug_keys.map do |key|
      if visit_attributes[key].present?
        { id: uuid({ visit_id: visit.id, name: key }),
          name: visit_attributes[key].humanize,
          dosage: visit_attributes[key] || '',
          is_deleted: true,
          patient_id: patient.patient_uuid,
          facility_id: visit.facility.simple_uuid,
          is_protocol_drug: false,
          created_at: device_created_at(visit),
          updated_at: device_created_at(visit) }
      else
        nil
      end
    end

    (common_drugs + custom_drugs).reject(&:nil?)
  end
end