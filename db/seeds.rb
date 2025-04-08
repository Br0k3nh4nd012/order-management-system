# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

items = Item.create!([
  { name: "Paneer Butter Masala", price: 250 },
  { name: "Veg Biryani", price: 180 },
  { name: "Masala Dosa", price: 120 },
  { name: "Roti", price: 50 },
])

customers = Customer.create!([
  { name: "John Doe", email: "john@example.com" },
  { name: "Jane Doe", email: "jane@example.com" },
])

items.each do |item|
  InventoryItem.create!(item: item, quantity: 50, threshold: 10)
end

customers.each do |customer|
  _order = Order.create!(customer: customer)
  _order.order_items.create!(item: items.sample, quantity: rand(1..5))
end