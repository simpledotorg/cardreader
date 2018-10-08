require 'net/http'

class SyncPrescriptionDrugService
  attr_reader :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze
  ERROR_FILE_PREFIX = 'prescription-drugs-errors-'

  def drug_keys
    %w(amlodipine telmisartan enalpril chlorthalidone aspirin statin
       beta_blocker losartan medication1_name medication2_name medication3_name)
  end

  def custom_drug_keys
    Set['medication1_name', 'medication2_name', 'medication3_name']
  end

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def api_post(path, request_body)
    uri = URI.parse(host + path)
    header = { 'Content-Type' => 'application/json',
               'ACCEPT' => 'application/json',
               'X-USER-ID' => user_id,
               'Authorization' => "Bearer #{access_token}" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end

  def sync
    request = Patient.all.flat_map { |patient| prescription_drugs(patient) }
    response = api_post('api/v1/prescription_drugs/sync', { prescription_drugs: request })
    errors = JSON(response.body)['errors'].map do |error|
      Visit.find_by(fix_this: error['id']).attributes.merge(error: error.except('id'))
    end
    write_errors_to_file(errors)
  end

  def device_created_at(visit)
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end


  def drug_present?(drug_value)
    !!drug_value.match(/Y/) if drug_value.present?
  end

  def drug_dosage(drug_value)
    drug_value.match(/\d*\s*mg/i).to_s.downcase
  end

  def custom_drug_name(drug_value)
    drug_value.match(/\b [A-z]{3,} \b/x).to_s
  end

  def get_drug_name(drug_name, drug_value)
    if custom_drug_keys.include? drug_name
      custom_drug_name(drug_value).downcase
    else
      drug_name.downcase
    end
  end

  def uuid(uniq_hash)
    UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, uniq_hash.to_s).to_s
  end

  def to_prescription_drug(patient, visit, drug_name, drug_value)
    { id: uuid({ visit_id: visit.id, name: drug_name }),
      name: get_drug_name(drug_name, drug_value),
      dosage: drug_dosage(drug_value),
      is_deleted: false,
      patient_id: patient.patient_uuid,
      facility_id: visit.facility.try(:simple_uuid),
      created_at: device_created_at(visit),
      updated_at: device_created_at(visit) }
  end

  def mark_older_prescriptions_as_deleted(drugs)
    drugs_across_visits = drugs.group_by { |drug| drug[:created_at] }.sort.reverse
    new_drugs = drugs_across_visits.take(1).to_h.values.flatten
    older_drugs = drugs_across_visits.drop(1).to_h.values.flatten
    older_drugs.map { |drug| drug[:is_deleted] = true; drug }.concat new_drugs
  end

  def carry_over_dosages(drugs_across_visits)
    drugs_across_visits.inject({ dosages: {}, drugs: [] }) do |acc, drug|
      if drug[:dosage].present?
        acc[:dosages][drug[:name]] = drug[:dosage].to_s
      else
        drug[:dosage] = acc[:dosages][drug[:name]].to_s
      end
      acc[:drugs] << drug
      acc
    end
  end

  def prescription_drugs(patient)
    visits = patient.visits.order(:measured_on)
    drugs_across_visits = visits.flat_map do |visit|
      visit.slice(*drug_keys)
        .select { |_, v| drug_present?(v) }
        .map { |drug_name, drug_value| to_prescription_drug(patient, visit, drug_name, drug_value) }
    end
    mark_older_prescriptions_as_deleted(carry_over_dosages(drugs_across_visits)[:drugs])
  end

  def write_errors_to_file(errors)
    return unless errors.present?
    error_file = ERROR_FILE_PREFIX + Time.now.to_i.to_s + ".csv"
    CSV.open(error_file, "wb") do |csv|
      csv << errors.first.keys # adds the attributes name on the first line
      errors.each do |error|
        csv << error.values
      end
    end
  end
end