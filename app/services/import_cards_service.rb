class ImportCardsService

  START_COLUMN_INDEX = 3
  MAX_NUMBER_OF_VISITS = 9

  def initialize(file_uri)
    @file_uri = file_uri
  end

  def import_patient(column)
    facility_name = get_value(:facility, :name, column) || ""
    facility = Facility.find_by('lower(name) = ?', facility_name.split.join(" ").downcase)
    if facility.present?
      patient = save_patient(facility, column)
      save_visits(patient, facility, column)
    else
      puts "Skipping #{get_value(:patient, :name, column)}; Facility #{facility_name} not found"
    end
  end

  def import
    file = Roo::Spreadsheet.open(file_uri)
    for column_index in START_COLUMN_INDEX..file.last_column
      column = file.column(column_index)
      begin
        import_patient(column)
      rescue => error
        puts "Could not import patient #{get_value(:patient, :name, column)}", error.message
      end
    end
  end

  private

  attr_reader :file_uri

  def patient_id_attributes
    Set[:facility_id, :treatment_number]
  end

  def visit_id_attributes
    Set[:measured_on, :patient_id]
  end

  def save_patient(facility, column)
    attributes =
      {}.merge(get_values(:patient, column))
        .merge(get_values(:medical_history, column))
        .merge(get_values(:hypertension_treatment_at_registration, column))
        .merge(facility_id: facility.id)

    existing_patient = Patient.find_by(attributes.slice(*uniquely_identifying_attributes))
    if existing_patient.present?
      existing_patient.update(attributes)
      existing_patient
    else
      Patient.create(attributes)
    end
  end

  def save_visits(patient, facility, column)
    for i in 1..9
      attributes = get_visit_values(i, column)
      begin
        create_or_update_visit(attributes, facility, patient)
      rescue => error
        puts "Could not create visit #{i + 1} for patient #{patient.name}", error.message
      end
    end
  end

  def create_or_update_visit(attributes, facility, patient)
    if attributes[:measured_on].present?
      attributes_with_ids = attributes.merge(patient_id: patient.id, facilities_id: facility.id)
      existing_visit = Visit.find_by(attributes_with_ids.slice(*visit_id_attributes))
      if existing_visit.present?
        existing_visit.update(attributes_with_ids)
      else
        Visit.create(attributes_with_ids)
      end
    end
  end

  def get_values(key, column)
    data_row_numbers[key].keys.inject({}) do |hash, sub_key|
      hash.merge(sub_key => get_value(key, sub_key, column))
    end
  end

  def get_visit_values(index, column)
    key = ('visit' + index.to_s).to_sym
    visit_row_delta.keys.inject({}) do |hash, sub_key|
      hash.merge(sub_key => column[data_row_numbers[key] + visit_row_delta[sub_key] - 1])
    end
  end

  def get_value(key, sub_key, column)
    column[data_row_numbers[key][sub_key] - 1]
  end

  def data_row_numbers
    { facility: { name: 1, district: 2 },
      patient: {
        registered_on: 5,
        treatment_number: 6,
        alternate_id_number: 7,
        name: 8,
        gender: 9,
        age: 10,
        house_number: 11,
        street_name: 12,
        area: 13,
        village: 14,
        district: 15,
        pincode: 16,
        phone: 17,
        alternate_phone: 18
      },
      medical_history: {
        already_on_treatment: 20,
        prior_heart_attack: 21,
        heard_attack_in_last_3_years: 22,
        prior_stroke: 23,
        chronic_kidney_disease: 24
      },
      hypertension_treatment_at_registration: {
        medication1_name: 25,
        medication1_dose: 26,
        medication2_name: 27,
        medication2_dose: 28,
        medication3_name: 29,
        medication3_dose: 30,
        medication4_name: 31,
        medication4_dose: 32,
      },
      visit1: 33,
      visit2: 50,
      visit3: 67,
      visit4: 84,
      visit5: 101,
      visit6: 118,
      visit7: 135,
      visit8: 152,
      visit9: 169
    }
  end

  def visit_row_delta
    { measured_on: 0,
      systolic: 1,
      diastolic: 2,
      blood_sugar: 3,
      amlodipine: 4,
      telmisartan: 5,
      enalpril: 6,
      chlorthalidone: 7,
      aspirin: 8,
      statin: 9,
      beta_blocker: 10,
      losartan: 11,
      medication1_name: 12,
      medication2_name: 13,
      medication3_name: 14,
      referred_to_specialist: 15,
      next_visit_on: 16
    }
  end
end