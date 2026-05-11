class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :confirmable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true, length: { maximum: 100 }
end
