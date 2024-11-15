# frozen_string_literal: true

require "rails_helper"

RSpec.describe Purchase, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:buy_order) }
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:buyer).class_name("User") }
  end

  describe "validations" do
    subject(:purchase) { create(:purchase) }

    it { is_expected.to validate_presence_of(:quantity) }

    it do
      expect(purchase).to validate_numericality_of(:quantity)
        .only_integer
        .is_greater_than(0)
    end

    it { is_expected.to validate_presence_of(:price_cents) }

    it do
      expect(purchase).to validate_numericality_of(:price_cents)
        .only_integer
        .is_greater_than(0)
    end
  end
end
