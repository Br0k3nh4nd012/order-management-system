class OrderStatusMailer < ApplicationMailer

    def order_status_change(order_id)
        @order = Order.find_by(id: order_id)
        return if @order.blank?
        
        mail(to: @order.customer.email, subject: "Order Status Changed")
    end
end
