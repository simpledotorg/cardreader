class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits

  delegate :facility, to: :patient

  validates :measured_on, presence: true

  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true,
                 after: :measured_on, after_message: "must be later than the date attended"
end
