class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits
end
