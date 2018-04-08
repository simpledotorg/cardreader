class Facility < ApplicationRecord
  has_many :patients

  validates :district, presence: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :district, message: "should be unique per district" }
end
