class SyncPrescriptionDrugPayload
  attr_reader :patient, :user_id

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_payload
    visits = patient.visits
    return [] unless visits.present?
    requests = visits.map { |visit| prescription_drug_payload(visit) }.compact
    mark_active_drugs(requests).flatten
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

  def device_created_at(visit)
    visit.measured_on_without_timestamp
  end

  def uuid_hash(drug_name)
    { patient_id: patient.patient_uuid, facility_id: patient.facility.simple_uuid, name: drug_name }
  end

  def mark_active_drugs(presciption_drugs)
    return [] unless presciption_drugs.present?
    deleted_drugs = presciption_drugs[0...-1]
    active_drugs = presciption_drugs.last.map { |drug| drug[:is_deleted] = false } if requests.present?
    deleted_drugs + active_drugs
  end

  def build_payload(drug_name, visit)
    drug_dosage = visit.read_attribute(drug_name)
    if drug_dosage.present?
      { id: uuid(uuid_hash(drug_name)),
        name: drug_name.humanize,
        dosage: drug_dosage || '',
        is_deleted: true,
        patient_id: patient.patient_uuid,
        facility_id: visit.facility.simple_uuid,
        is_protocol_drug: protocol_drug_keys.include?(drug_name),
        created_at: device_created_at(visit),
        updated_at: device_created_at(visit) }
    else
      nil
    end
  end

  def prescription_drug_payload(visit)
    common_drugs = common_drug_keys.map do |drug_name|
      build_payload(drug_name, visit)
    end

    custom_drugs = custom_drug_keys.map do |custom_drug_name|
      drug_name = visit.read_attribute(custom_drug_name)
      payload = build_payload(drug_name, visit)
      payload.merge(
        dosage: visit.read_attribute(custom_drug_name.split('_').first + "_dosage") || ''
      ) if payload.present?
    end

    (common_drugs + custom_drugs).compact
  end
end