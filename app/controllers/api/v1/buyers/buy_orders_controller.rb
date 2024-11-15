# frozen_string_literal: true

module Api
  module V1
    module Buyers
      class BuyOrdersController < ApplicationController
        before_action :set_business

        def create
          authorize BuyOrder

          @buy_order = @business.buy_orders.new(buy_order_params)
          @buy_order.buyer = current_user

          if @buy_order.save
            render_success
          else
            render_error
          end
        end

        private

        def set_business
          @business = Business.find_by(id: params[:business_id])
          return if @business

          render json: { error: "Business not found" }, status: :not_found
        end

        def buy_order_params
          params.require(:buy_order).permit(:quantity, :price)
        end

        def render_success
          buy_order_json = @buy_order.as_json(
            only: %i[id business_id buyer_id quantity status created_at updated_at],
            methods: [:buyer_username]
          )
          buy_order_json[:price] = @buy_order.price.to_f

          render json: buy_order_json, status: :created
        end

        def render_error
          render json: { errors: @buy_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end