# frozen_string_literal: true

class Purchase < ApplicationRecord
  # Associations
  belongs_to :buy_order
  belongs_to :business
  belongs_to :buyer, class_name: "User"

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }

  monetize :price_cents

  delegate :username, to: :buyer, prefix: true
end
