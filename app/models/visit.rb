class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits

  delegate :facility, to: :patient

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  validates :measured_on, presence: true
  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true,
                 after: :measured_on, after_message: "must be later than the date attended"

  def measured_on_without_timestamp
    self.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def synced?
    synced_at.present? && (synced_at >= updated_at)
  end
end