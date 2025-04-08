class OrderStatusMailer < ApplicationMailer

    def order_status_change(order)
        @order = order
        mail(to: order.customer.email, subject: "Order Status Changed")
    end
end
