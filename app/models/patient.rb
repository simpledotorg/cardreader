class Patient < ApplicationRecord
  belongs_to :facility, inverse_of: :patients
  has_many :blood_pressures, inverse_of: :patient, dependent: :destroy

  accepts_nested_attributes_for :blood_pressures, reject_if: :all_blank

  def treatment_number=(new_treatment_number)
    formatted_treatment_number = "2018-%08i" % new_treatment_number
    write_attribute(:treatment_number, formatted_treatment_number)
  end
end
