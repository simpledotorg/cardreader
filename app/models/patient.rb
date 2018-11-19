class Patient < ApplicationRecord
  include Syncable

  belongs_to :facility, inverse_of: :patients
  has_many :visits, inverse_of: :patient, dependent: :destroy

  validates_date :registered_on

  validates :treatment_number, presence: true
  validates :treatment_number, uniqueness: {
    scope: :facility_id,
    message: "should be unique per facility",
    case_sensitive: false
  }

  TREATMENT_NUMBER_DIGITS = 8.freeze

  def formatted_treatment_number
    treatment_number_prefix + treatment_number.to_s
  end

  def treatment_number_prefix
    return "" unless treatment_number_needs_prefix?

    prefix = "2018-"
    prefix += "0" * [TREATMENT_NUMBER_DIGITS - treatment_number.to_s.length, 0].max

    prefix
  end

  def first_visit
    visits.order(measured_on: :asc).first
  end

  def last_visit
    visits.order(measured_on: :desc).first
  end

  def registered_on_without_timestamp
    if first_visit.present?
      first_visit.measured_on_without_timestamp
    else
      Time.now
    end
  end

  private

  def treatment_number_needs_prefix?
    true if treatment_number.nil? || Integer(treatment_number) rescue false
  end
end
