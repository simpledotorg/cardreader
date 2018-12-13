class District < ApplicationRecord
  has_many :facilities, inverse_of: :district

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
