class Facility < ApplicationRecord
  belongs_to :district, inverse_of: :facilities
  belongs_to :user

  has_many :patients, inverse_of: :facility, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :district_id, message: "should be unique per district", case_sensitive: false }

  validates :district, presence: true
end
