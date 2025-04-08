class Order < ApplicationRecord
    ## Associations ##
    has_many :order_items
    belongs_to :customer

    
    enum :status, {
        cancelled: 0,
        placed: 1,
        preparing: 2,
        out_for_delivery: 3,
        delivered: 4
    }

    ## Validations ##
    validates :status, presence: true
    validates :customer, presence: true

    ## Callbacks ##
    before_validation :set_status, on: :create


    def update_status(status)
        puts "Updating status to #{status}"
        if status == 0
            self.status = :cancelled
        else
            self.status = status
        end
        save!
        update_inventory
    end

    def notify_customer
        OrderStatusMailer.order_status_change(self).deliver_later
    end

    private

    def set_status
        self.status = :placed
    end

    def update_inventory
        order_items.each do |order_item|
            puts "Updating inventory for item #{order_item.item_id}"
            inventory_item = InventoryItem.find_by(item_id: order_item.item_id)
            inventory_item.with_lock do
                inventory_item.update!(quantity: inventory_item.quantity + order_item.quantity)
            end
        end
    end
end
