class Patient < ApplicationRecord
  belongs_to :facility, inverse_of: :patients
  has_many :blood_pressures, inverse_of: :patient, dependent: :destroy

  accepts_nested_attributes_for :blood_pressures, reject_if: :all_blank

  def treatment_number=(new_treatment_number)
    if reformat_treatment_number?(new_treatment_number)
      new_treatment_number = "2018-%08i" % new_treatment_number
    end

    write_attribute(:treatment_number, new_treatment_number)
  end

  private

  def reformat_treatment_number?(new_treatment_number)
    true if Integer(new_treatment_number) rescue false
  end
end
