class Order < ApplicationRecord
    ## Associations ##
    has_many :order_items, dependent: :destroy
    belongs_to :customer

    
    enum :status, {
        cancelled: 0,
        placed: 1,
        preparing: 2,
        out_for_delivery: 3,
        delivered: 4
    }
    attr_accessor :do_follow_up

    ## Validations ##
    validates :status, presence: true
    validates :customer, presence: true

    ## Callbacks ##
    before_validation :set_status, on: :create
    after_commit :follow_up_actions, if: -> { previous_changes.key?('status') || do_follow_up }


    def follow_up_actions
        OrderStatusChangeJob.perform_later(id)
    end

    def update_status(_status)
        puts "Updating status to #{status}"
        if _status == 0 || _status == 'cancelled'
            self.status = :cancelled
            update_inventory
        else
            self.status = _status
        end
        save!
    end

    def notify_customer
        OrderStatusMailer.order_status_change(id).deliver_later
    end

    private

    def set_status
        self.status = :placed
        self.do_follow_up = true
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
