class Patient < ApplicationRecord
  belongs_to :facility, inverse_of: :patients
  has_many :visits, inverse_of: :patient, dependent: :destroy

  accepts_nested_attributes_for :visits, reject_if: :all_blank

  TREATMENT_NUMBER_DIGITS = 8.freeze

  def formatted_treatment_number
    treatment_number_prefix + treatment_number
  end

  def treatment_number_prefix
    return "" unless treatment_number_needs_prefix?

    prefix = "2018-"
    prefix += "0" * [TREATMENT_NUMBER_DIGITS - treatment_number.length, 0].max

    prefix
  end

  private

  def treatment_number_needs_prefix?
    true if Integer(treatment_number) rescue false
  end
end
