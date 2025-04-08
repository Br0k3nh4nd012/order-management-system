class OrderStatusChangeJob < ApplicationJob 
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return if order.nil?

    # Notify the customer
    puts "Notifying customer for order #{order_id}"
    order.notify_customer

    # update the analytics

    # update the analytics
    puts "Updating analytics for order #{args[0]}"



    #notify external systems
    puts "Notifying external systems for order #{args[0]}"


  end
end
