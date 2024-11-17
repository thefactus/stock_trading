# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Purchase.destroy_all
BuyOrder.destroy_all
Business.destroy_all
User.destroy_all

owner1 = User.create!(
  email: "owner1@example.com",
  password: "password",
  password_confirmation: "password",
  role: "owner",
  username: "owner1"
)

owner2 = User.create!(
  email: "owner2@example.com",
  password: "password",
  password_confirmation: "password",
  role: "owner",
  username: "owner2"
)

buyer1 = User.create!(
  email: "buyer1@example.com",
  password: "password",
  password_confirmation: "password",
  role: "buyer",
  username: "buyer1"
)

buyer2 = User.create!(
  email: "buyer2@example.com",
  password: "password",
  password_confirmation: "password",
  role: "buyer",
  username: "buyer2"
)

puts "Created #{User.count} users."

business1 = Business.create!(
  name: "TechCorp",
  total_shares: 5000,
  available_shares: 5000,
  owner: owner1
)

business2 = Business.create!(
  name: "HealthPlus",
  total_shares: 4000,
  available_shares: 4000,
  owner: owner1
)

business3 = Business.create!(
  name: "Foodies",
  total_shares: 3000,
  available_shares: 0,
  owner: owner1
)

business4 = Business.create!(
  name: "TravelNow",
  total_shares: 6000,
  available_shares: 0,
  owner: owner1
)

business5 = Business.create!(
  name: "EduSmart",
  total_shares: 4500,
  available_shares: 4500,
  owner: owner1
)

business6 = Business.create!(
  name: "EcoEnergy",
  total_shares: 4000,
  available_shares: 4000,
  owner: owner2
)

business7 = Business.create!(
  name: "FashionHub",
  total_shares: 3500,
  available_shares: 3500,
  owner: owner2
)

business8 = Business.create!(
  name: "HomeComfort",
  total_shares: 4800,
  available_shares: 0,
  owner: owner2
)

business9 = Business.create!(
  name: "AutoDrive",
  total_shares: 5200,
  available_shares: 0,
  owner: owner2
)

business10 = Business.create!(
  name: "FinServ",
  total_shares: 3700,
  available_shares: 3700,
  owner: owner2
)

puts "Created #{Business.count} businesses."

puts "Creating buy orders..."

begin
  buy_order1 = CreateBuyOrderService.call(
    business1,
    { quantity: 1000, price_cents: 50_000 },
    buyer1
  )

  buy_order2 = CreateBuyOrderService.call(
    business2,
    { quantity: 1500, price_cents: 75_000 },
    buyer2
  )
rescue StandardError => e
  puts "Error creating buy orders: #{e.message}"
end

puts "Updating buy orders..."

begin
  UpdateBuyOrderService.call(buy_order1, "accepted")
  puts "Buy order #{buy_order1.id} accepted by owner1."

  UpdateBuyOrderService.call(buy_order2, "rejected")
  puts "Buy order #{buy_order2.id} rejected by owner1."
rescue StandardError => e
  puts "Error updating buy orders: #{e.message}"
end

puts "Updated Buy Orders."
