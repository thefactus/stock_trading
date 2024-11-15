# frozen_string_literal: true

class BuyOrder < ApplicationRecord
  # Scopes
  scope :pending, -> { where(status: "pending") }

  # Enums
  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }, validate: true

  # Associations
  belongs_to :business
  belongs_to :buyer, class_name: "User"

  # Validations
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  monetize :price_cents

  delegate :username, to: :buyer, prefix: true
end
