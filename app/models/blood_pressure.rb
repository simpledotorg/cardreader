class BloodPressure < ApplicationRecord
  belongs_to :patient, inverse_of: :blood_pressures
end
