class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :certifications, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
end
