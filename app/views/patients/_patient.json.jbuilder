json.extract! patient, :id, :card_id, :registered_on, :facility_id, :created_at, :updated_at
json.url patient_url(patient, format: :json)
