# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

items = 100.times.map do |i|
  Item.create!(
    name: "Item #{i + 1}",
    price: rand(50..500)
  )
end

customers = 100.times.map do |i|
  Customer.create!(
    name: "Customer #{i + 1}",
    email: "customer#{i + 1}@example.com",
    phone: "12345678#{i + 1}"
  )
end

items.each do |item|
  InventoryItem.create!(item: item, quantity: 50, threshold: 10)
end

customers.each do |customer|
  _order = Order.create!(customer: customer)
  _order.order_items.create!(item: items.sample, quantity: rand(1..5))
  _order.total_price = _order.order_items.sum(:price)
  _order.save!
end
