# frozen_string_literal: true

FactoryBot.define do
  factory :purchase do
    buy_order
    business
    buyer { association :user }
    quantity { 10 }
    price_cents { 1000 }
  end
end
