# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Buyers::BuyOrders", type: :request do
  describe "POST /api/v1/buyers/businesses/:business_id/buy_orders" do
    subject(:create_buy_order) do
      post "/api/v1/buyers/businesses/#{business.id}/buy_orders", params: params, headers: headers, as: :json
    end

    let(:password) { "password123" }
    let(:buyer) { create(:user, role: :buyer, password: password, password_confirmation: password) }
    let(:owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
    let(:business) { create(:business, owner: owner, available_shares: 100) }
    let(:headers) { basic_auth_headers(buyer.email, password) }

    context "when the request is valid" do
      let(:params) do
        {
          buy_order: {
            quantity: 10,
            price: 50.0
          }
        }
      end

      it "creates a new buy order" do
        expect { create_buy_order }.to change(BuyOrder, :count).by(1)
        expect(response).to conform_schema(201)

        json_response = response.parsed_body
        expect(json_response["quantity"]).to eq(10)
        expect(json_response["price"]).to eq(50.0)
        expect(json_response["status"]).to eq("pending")
      end
    end

    context "when the request is invalid" do
      let(:params) do
        {
          buy_order: {
            quantity: -5,
            price: 0
          }
        }
      end

      it "does not create a buy order and returns errors" do
        expect { create_buy_order }.not_to change(BuyOrder, :count)
        expect(response).to conform_schema(422)
        expect(response.parsed_body["errors"]).to include("Quantity must be greater than 0",
                                                          "Price cents must be greater than 0")
      end
    end

    context "when the business does not exist" do
      subject(:create_buy_order) do
        post "/api/v1/buyers/businesses/99999/buy_orders", params: params, headers: headers, as: :json
      end

      let(:params) do
        {
          buy_order: {
            quantity: 10,
            price: 50.0
          }
        }
      end

      it "returns a not found error" do
        create_buy_order
        expect(response).to conform_schema(404)
        expect(response.parsed_body["error"]).to eq("Business not found")
      end
    end

    context "when not authenticated" do
      let(:headers) { basic_auth_headers("", "") }
      let(:params) do
        {
          buy_order: {
            quantity: 10,
            price: 50.0
          }
        }
      end

      it "returns unauthorized error" do
        create_buy_order
        expect(response).to conform_schema(401)
        expect(response.parsed_body["error"]).to eq("Invalid credentials")
      end
    end

    context "when authenticated as an owner" do
      let(:headers) { basic_auth_headers(owner.email, password) }
      let(:params) do
        {
          buy_order: {
            quantity: 10,
            price: 50.0
          }
        }
      end

      it "returns forbidden error" do
        create_buy_order
        expect(response).to conform_schema(403)
        expect(response.parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when the business does not have enough available shares" do
      let(:params) do
        {
          buy_order: {
            quantity: 200,
            price: 50.0
          }
        }
      end

      it "does not create a buy order and returns an error message" do
        expect { create_buy_order }.not_to change(BuyOrder, :count)
        expect(response).to conform_schema(422)
        expect(response.parsed_body["error"]).to eq("Not enough available shares to fulfill this order.")
      end
    end
  end
end
