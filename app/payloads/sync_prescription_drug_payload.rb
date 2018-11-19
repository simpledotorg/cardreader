class SyncPrescriptionDrugPayload
  attr_reader :patient, :visit, :user_id, :now

  PROTOCOL_DRUG_KEYS = %w(amlodipine telmisartan chlorthalidone).freeze
  COMMON_DRUG_KEYS = %w(amlodipine telmisartan enalpril chlorthalidone aspirin statin beta_blocker losartan).freeze
  CUSTOM_DRUG_KEYS = %w(medication1_name medication2_name medication3_name).freeze

  def initialize(visit, user_id)
    @visit = visit
    @patient = visit.patient
    @user_id = user_id
    @now = Time.now
  end

  def to_payload
    request = prescription_drug_payload(visit)
    mark_active_drug(request)
  end

  def uuid(uniq_hash)
    UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, uniq_hash.to_s).to_s
  end

  def uuid_hash(drug_name, drug_dosage, measured_on)
    { patient_id: patient.patient_uuid,
      facility_id: patient.facility.simple_uuid,
      name: drug_name,
      dosage: drug_dosage,
      measured_on: measured_on }
  end

  def mark_active_drug(prescription_drug)
    return nil if prescription_drug.nil?

    if visit.last?
      prescription_drug.merge(is_deleted: false)
    else
      prescription_drug
    end
  end

  def build_payload(drug_name, drug_dosage, visit)
    if drug_dosage.present?
      { id: uuid(uuid_hash(drug_name, drug_dosage, visit.measured_on_without_timestamp)),
        name: drug_name.humanize,
        dosage: drug_dosage || '',
        is_deleted: true,
        patient_id: patient.patient_uuid,
        facility_id: visit.facility.simple_uuid,
        is_protocol_drug: PROTOCOL_DRUG_KEYS.include?(drug_name),
        created_at: visit.measured_on_without_timestamp,
        updated_at: now }
    else
      nil
    end
  end

  def prescription_drug_payload(visit)
    common_drugs = COMMON_DRUG_KEYS.map do |drug_name|
      drug_dosage = visit.read_attribute(drug_name)
      build_payload(drug_name, drug_dosage, visit)
    end

    custom_drugs = CUSTOM_DRUG_KEYS.map do |custom_drug_name|
      drug_name = visit.read_attribute(custom_drug_name)
      drug_dosage = visit.read_attribute(custom_drug_name.split('_').first + "_dose")
      build_payload(drug_name, drug_dosage, visit)
    end

    (common_drugs + custom_drugs).compact
  end
end