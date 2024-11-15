# frozen_string_literal: true

FactoryBot.define do
  factory :business do
    name { Faker::Company.name }
    total_shares { 1000 }
    available_shares { 500 }
    owner { association :user, role: "owner" }
  end
end
