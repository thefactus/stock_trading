# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "enums" do
    it "has the correct statuses" do
      expect(described_class.roles.keys).to contain_exactly("buyer", "owner")
    end
  end

  describe "validations" do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end
end
