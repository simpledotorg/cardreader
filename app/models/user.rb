class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :invitable,
         :recoverable, :rememberable, :validatable

  enum role: [
    :admin,
    :operator
  ]

  has_many :facilities
  has_many :patients
  has_many :visits

  validates :role, presence: true
end
