# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Owners::Businesses", type: :request do
  describe "GET /api/v1/owners/businesses" do
    subject(:fetch_businesses) { get "/api/v1/owners/businesses", headers: headers }

    let(:password) { "password123" }
    let(:owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
    let(:buyer) { create(:user, role: :buyer, password: password, password_confirmation: password) }

    before do
      create(:business, name: "Business A", available_shares: 100, owner: owner)
      create(:business, name: "Business B", available_shares: 50, owner: owner)

      other_owner = create(:user, role: :owner, password: password, password_confirmation: password)
      create(:business, name: "Business C", available_shares: 70, owner: other_owner)
    end

    context "when authenticated as an owner" do
      let(:headers) { basic_auth_headers(owner.email, password) }

      it "returns a list of the owner's businesses" do
        fetch_businesses
        expect(response).to conform_schema(200)

        business_names = response.parsed_body.pluck("name")
        expect(business_names).to include("Business A", "Business B")
        expect(business_names).not_to include("Business C")
      end
    end

    context "when authenticated as a buyer" do
      let(:headers) { basic_auth_headers(buyer.email, password) }

      it "returns a 403 Forbidden error" do
        fetch_businesses
        expect(response).to conform_schema(403)

        json_response = response.parsed_body
        expect(json_response["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when not authenticated" do
      let(:headers) { basic_auth_headers("", "") }

      it "returns a 401 Unauthorized error" do
        fetch_businesses
        expect(response).to conform_schema(401)

        json_response = response.parsed_body
        expect(json_response["error"]).to eq("Invalid credentials")
      end
    end
  end
end
