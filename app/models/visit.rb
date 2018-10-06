class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits
  belongs_to :facility, foreign_key: 'facilities_id'

  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true
end
