# frozen_string_literal: true

require "rails_helper"

RSpec.describe BuyOrder, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:buyer).class_name("User") }
  end

  describe "validations" do
    subject(:buy_order) { build(:buy_order) }

    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }

    it "validates price is greater than zero" do
      buy_order.price = Money.new(0)
      expect(buy_order).not_to be_valid
      expect(buy_order.errors[:price_cents]).to include("must be greater than 0")
    end

    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending accepted rejected]) }
  end

  describe "monetize" do
    it { is_expected.to monetize(:price_cents).as(:price) }
  end

  describe "scopes" do
    describe ".pending" do
      let!(:pending_order) { create(:buy_order, status: "pending") }
      let!(:accepted_order) { create(:buy_order, status: "accepted") }

      it "includes orders with status pending" do
        expect(described_class.pending).to include(pending_order)
      end

      it "excludes orders with status not pending" do
        expect(described_class.pending).not_to include(accepted_order)
      end
    end
  end
end
