# frozen_string_literal: true

require "rails_helper"

RSpec.describe Business, type: :model do
  describe "scopes" do
    describe ".with_available_shares" do
      let!(:business_with_shares) { create(:business, available_shares: 10) }
      let!(:business_without_shares) { create(:business, available_shares: 0) }

      it "includes businesses with available shares greater than zero" do
        expect(described_class.with_available_shares).to include(business_with_shares)
      end

      it "excludes businesses with no available shares" do
        expect(described_class.with_available_shares).not_to include(business_without_shares)
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:owner).class_name("User") }
    # it { is_expected.to have_many(:buy_orders).dependent(:destroy) }
    # it { is_expected.to have_many(:purchases).dependent(:destroy) }
  end

  describe "validations" do
    subject(:business) { create(:business) }

    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(business).to validate_numericality_of(:total_shares)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(business).to validate_numericality_of(:available_shares)
        .only_integer
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(:total_shares)
    end
  end
end
