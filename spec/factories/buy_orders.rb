# frozen_string_literal: true

FactoryBot.define do
  factory :buy_order do
    business
    buyer { association :user, role: :buyer }
    quantity { 10 }
    price { Money.new(5000) }
    status { "pending" }
  end
end
