# frozen_string_literal: true

module Api
  module V1
    module Owners
      class BuyOrdersController < ApplicationController
        before_action :set_business
        before_action :set_buy_order, only: [:update]

        def index
          authorize BuyOrder, :index?

          @buy_orders = @business.buy_orders.includes(:buyer)
          render json: @buy_orders.map { |buy_order| buy_order_json(buy_order) }, status: :ok
        end

        def update
          authorize @buy_order

          begin
            UpdateBuyOrderService.call(@buy_order, buy_order_params[:status])
            render json: buy_order_json(@buy_order), status: :ok
          rescue UpdateBuyOrderService::NotEnoughAvailableSharesError => e
            render json: { error: e.message }, status: :unprocessable_entity
          rescue ActiveRecord::RecordInvalid => e
            render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def set_business
          @business = current_user.businesses.find_by(id: params[:business_id])
          return if @business

          render json: { error: "Business not found" }, status: :not_found
        end

        def set_buy_order
          @buy_order = @business.buy_orders.find_by(id: params[:id])
          return if @buy_order

          render json: { error: "Buy order not found" }, status: :not_found
        end

        def buy_order_params
          params.require(:buy_order).permit(:status)
        end

        def buy_order_json(buy_order)
          buy_order_data = buy_order.as_json(
            only: %i[id business_id buyer_id quantity status created_at updated_at],
            methods: [:buyer_username]
          )
          buy_order_data["price"] = buy_order.price.to_f
          buy_order_data
        end
      end
    end
  end
end
