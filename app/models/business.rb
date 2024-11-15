# frozen_string_literal: true

class Business < ApplicationRecord
  # Scopes
  scope :with_available_shares, -> { where("available_shares > 0") }

  # Associations
  belongs_to :owner,
             class_name: "User",
             inverse_of: :businesses
  has_many :buy_orders, dependent: :destroy
  has_many :purchases, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :total_shares, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :available_shares, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: :total_shares
  }
end
