class User < ApplicationRecord
  devise :database_authenticatable
  validates :name, :email, presence: true, uniqueness: true
end
