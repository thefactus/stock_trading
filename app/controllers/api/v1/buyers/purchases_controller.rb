# frozen_string_literal: true

module Api
  module V1
    module Buyers
      class PurchasesController < ApplicationController
        before_action :set_business

        def index
          authorize @business, :view_purchases?

          @purchases = @business.purchases.includes(:buyer)

          render json: @purchases.map { |purchase| purchase_json(purchase) }, status: :ok
        end

        private

        def set_business
          @business = Business.find_by(id: params[:business_id])
          render json: { error: "Business not found" }, status: :not_found unless @business
        end

        def purchase_json(purchase)
          purchase_data = purchase.as_json(
            only: %i[id buy_order_id business_id quantity created_at],
            methods: [:buyer_username]
          )
          purchase_data["price"] = purchase.price.to_f
          purchase_data
        end
      end
    end
  end
end
