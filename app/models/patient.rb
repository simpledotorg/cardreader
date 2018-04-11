class Patient < ApplicationRecord
  belongs_to :facility
  has_many :blood_pressures, dependent: :destroy
end
