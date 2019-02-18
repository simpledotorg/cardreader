class District < ApplicationRecord
  has_many :facilities, inverse_of: :district
  has_many :patients, through: :facilities

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
