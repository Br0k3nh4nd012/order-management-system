# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

products = Item.create!([
  { name: "Paneer Butter Masala", price: 250 },
  { name: "Veg Biryani", price: 180 },
  { name: "Masala Dosa", price: 120 },
  { name: "Roti", price: 50 },
])

products.each do |product|
  InventoryItem.create!(product: product, quantity: 50, threshold: 10)
end