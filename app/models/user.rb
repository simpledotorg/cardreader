class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :invitable,
         :recoverable, :rememberable, :validatable

  enum role: [
    :admin,
    :operator
  ]

  has_many :facilities, inverse_of: :author
  has_many :patients, inverse_of: :author
  has_many :visits, inverse_of: :author

  validates :role, presence: true
end
