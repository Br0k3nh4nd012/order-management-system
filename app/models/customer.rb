class Customer < ApplicationRecord
    has_many :orders

    def notify_order_status_change(order)
        
    end
end
