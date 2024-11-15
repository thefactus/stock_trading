# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :businesses,
           foreign_key: "owner_id",
           class_name: "Business",
           dependent: :destroy,
           inverse_of: :owner

  # Enums
  enum :role, { buyer: "buyer", owner: "owner" }, validate: true

  # Validations
  validates :username, presence: true, uniqueness: true
end
