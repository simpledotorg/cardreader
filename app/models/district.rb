class District < ApplicationRecord
  has_many :facilities

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
