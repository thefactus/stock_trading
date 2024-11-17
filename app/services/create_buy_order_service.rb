# frozen_string_literal: true

class CreateBuyOrderService < ApplicationService
  class NotEnoughAvailableSharesError < StandardError; end

  def initialize(business, buy_order_params, buyer)
    super()
    @business = business
    @buy_order_params = buy_order_params
    @buyer = buyer
  end

  def call
    raise NotEnoughAvailableSharesError, "Not enough available shares to fulfill this order." unless sufficient_shares?

    create_buy_order
  end

  private

  attr_reader :business, :buy_order_params, :buyer

  def sufficient_shares?
    business.available_shares >= buy_order_params[:quantity].to_i
  end

  def create_buy_order
    buy_order = business.buy_orders.new(buy_order_params)
    buy_order.buyer = buyer
    buy_order.save!

    buy_order
  end
end
