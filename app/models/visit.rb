class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits

  delegate :facility, to: :patient

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true

  def measured_on_without_timestamp
    self.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end
end
