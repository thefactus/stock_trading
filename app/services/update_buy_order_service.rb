# frozen_string_literal: true

class UpdateBuyOrderService < ApplicationService
  class NotEnoughAvailableSharesError < StandardError; end

  def initialize(buy_order, new_status)
    super()
    @buy_order = buy_order
    @business = buy_order.business
    @new_status = new_status
  end

  def call
    ActiveRecord::Base.transaction do
      if accepting_order?
        accept_order
      else
        update_buy_order_status
      end
    end
    buy_order
  end

  private

  attr_reader :buy_order, :business, :new_status

  def accepting_order?
    new_status == "accepted" && buy_order.status != "accepted"
  end

  def accept_order
    business.lock!

    raise NotEnoughAvailableSharesError, "Not enough available shares to fulfill this order." unless sufficient_shares?

    business.available_shares -= buy_order.quantity
    business.save!
    buy_order.update!(status: "accepted")
    create_purchase
  end

  def update_buy_order_status
    buy_order.update!(status: new_status)
  end

  def sufficient_shares?
    business.available_shares >= buy_order.quantity
  end

  def create_purchase
    Purchase.create!(
      buy_order: buy_order,
      business: business,
      buyer: buy_order.buyer,
      quantity: buy_order.quantity,
      price_cents: buy_order.price_cents
    )
  end
end
