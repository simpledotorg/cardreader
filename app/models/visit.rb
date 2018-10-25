class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits

  delegate :facility, to: :patient

  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true
end
