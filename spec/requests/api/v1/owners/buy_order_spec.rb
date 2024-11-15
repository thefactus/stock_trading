# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Owners::BuyOrders", type: :request do
  let(:password) { "password123" }
  let(:owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
  let(:other_owner) { create(:user, role: :owner, password: password, password_confirmation: password) }
  let(:buyer) { create(:user, role: :buyer) }
  let(:business) { create(:business, owner: owner, total_shares: 1000, available_shares: 500) }
  let(:other_business) { create(:business, owner: other_owner, total_shares: 1000, available_shares: 500) }
  let(:headers) { basic_auth_headers(owner.email, password) }

  describe "PATCH /api/v1/owners/businesses/:business_id/buy_orders/:id" do
    subject(:update_buy_order) do
      patch "/api/v1/owners/businesses/#{business_id}/buy_orders/#{buy_order_id}", params: params, headers: headers,
                                                                                   as: :json
    end

    let(:business_id) { business.id }
    let(:buy_order) do
      create(:buy_order, business: business, buyer: buyer, status: "pending", quantity: 100, price: 50.0)
    end
    let(:buy_order_id) { buy_order.id }
    let(:params) { { buy_order: { status: "accepted" } } }

    context "when accepting a buy order" do
      it "updates the buy order status and decreases the business's available shares" do
        expect do
          update_buy_order
        end.to change { business.reload.available_shares }.by(-buy_order.quantity)
                                                          .and change(Purchase, :count).by(1)

        expect(response).to conform_schema(200)

        json_response = response.parsed_body
        expect(json_response["status"]).to eq("accepted")
        expect(json_response["price"]).to eq(50.0)

        purchase = Purchase.last
        expect(purchase.buy_order).to eq(buy_order)
        expect(purchase.business).to eq(business)
        expect(purchase.buyer).to eq(buyer)
        expect(purchase.quantity).to eq(buy_order.quantity)
        expect(purchase.price_cents).to eq(buy_order.price_cents)
      end
    end

    context "when rejecting a buy order" do
      let(:params) { { buy_order: { status: "rejected" } } }

      it "updates the buy order status" do
        expect do
          update_buy_order
        end.to change { buy_order.reload.status }.to("rejected")

        expect(response).to conform_schema(200)

        json_response = response.parsed_body
        expect(json_response["status"]).to eq("rejected")
        expect(json_response["price"]).to eq(50.0)
      end
    end

    context "when there are not enough available shares" do
      let(:buy_order) do
        create(:buy_order, business: business, buyer: buyer, status: "pending",
                           quantity: 10_000, price: 50.0)
      end

      it "does not accept the buy order and returns an error" do
        expect { update_buy_order }.not_to(change { business.reload.available_shares })
        expect(response).to conform_schema(422)
        expect(response.parsed_body["error"]).to eq("Not enough available shares to fulfill this order.")
      end
    end

    context "when updating with an invalid status" do
      let(:params) { { buy_order: { status: "invalid_status" } } }

      it "returns an unprocessable entity error" do
        update_buy_order
        expect(response).to conform_schema(422)
        expect(response.parsed_body["errors"]).to include("Status is not included in the list")
      end
    end

    context "when authenticated as a different owner" do
      let(:headers) { basic_auth_headers(other_owner.email, password) }
      let(:business_id) { business.id }

      it "returns a not found error" do
        update_buy_order
        expect(response).to conform_schema(404)

        expect(response.parsed_body["error"]).to eq("Business not found")
      end
    end
  end

  describe "GET /api/v1/owners/businesses/:business_id/buy_orders" do
    subject(:get_buy_orders) { get "/api/v1/owners/businesses/#{business_id}/buy_orders", headers: headers }

    let(:business_id) { business.id }

    before do
      create(:buy_order, business: business, buyer: buyer, quantity: 10, price: 50.0, status: "pending")
      create(:buy_order, business: business, buyer: buyer, quantity: 5, price: 30.0, status: "accepted")
      create(:buy_order, business: other_business, buyer: buyer, quantity: 8, price: 40.0, status: "pending")
    end

    context "when authenticated as the business owner" do
      it "returns a list of buy orders for the business" do
        get_buy_orders
        expect(response).to conform_schema(200)

        json_response = response.parsed_body
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(2)

        json_response.each do |buy_order|
          expect(buy_order["business_id"]).to eq(business.id)
        end
      end
    end

    context "when authenticated as a different owner" do
      let(:headers) { basic_auth_headers(other_owner.email, password) }

      it "returns a not found error" do
        get_buy_orders
        expect(response).to conform_schema(404)
        expect(response.parsed_body["error"]).to eq("Business not found")
      end
    end

    context "when the business does not exist" do
      let(:business_id) { 99_999 }

      it "returns a not found error" do
        get_buy_orders
        expect(response).to conform_schema(404)
        expect(response.parsed_body["error"]).to eq("Business not found")
      end
    end

    context "when not authenticated" do
      let(:headers) { basic_auth_headers("", "") }

      it "returns an unauthorized error" do
        get_buy_orders
        expect(response).to conform_schema(401)
        expect(response.parsed_body["error"]).to eq("Invalid credentials")
      end
    end
  end
end
