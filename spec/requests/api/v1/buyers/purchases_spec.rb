# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Buyers::Purchases", type: :request do
  describe "GET /api/v1/buyers/businesses/:business_id/purchases" do
    subject(:get_purchases) do
      get "/api/v1/buyers/businesses/#{business_id}/purchases", headers: headers, as: :json
    end

    let(:password) { "password123" }
    let(:buyer) { create(:user, role: :buyer, password: password, password_confirmation: password) }
    let(:business_owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
    let(:business) { create(:business, owner: business_owner) }
    let(:business_id) { business.id }
    let(:purchases) { create_list(:purchase, 3, business: business, buyer: buyer) }
    let(:headers) { basic_auth_headers(buyer.email, password) }

    context "when the request is valid" do
      before { purchases }

      it "returns a list of purchases" do
        get_purchases
        expect(response).to conform_schema(200)
        expect(response.parsed_body.size).to eq(3)
      end
    end

    context "when the business does not exist" do
      let(:business_id) { 0 }

      it "returns a not found message" do
        get_purchases
        expect(response).to conform_schema(404)
        expect(response.parsed_body["error"]).to eq("Business not found")
      end
    end

    context "when the user is unauthorized" do
      let(:headers) { basic_auth_headers("invalid@example.com", "wrongpassword") }

      it "returns an unauthorized error message" do
        get_purchases
        expect(response).to conform_schema(401)
        expect(response.parsed_body["error"]).to eq("Invalid credentials")
      end
    end

    context "when the user is not authorized to view purchases" do
      let(:owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
      let(:headers) { basic_auth_headers(owner.email, password) }

      it "returns a forbidden error message" do
        get_purchases
        expect(response).to conform_schema(403)
        expect(response.parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
