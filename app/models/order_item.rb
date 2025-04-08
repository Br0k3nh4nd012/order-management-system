class OrderItem < ApplicationRecord
    ## Associations ##
    belongs_to :order 
    belongs_to :item

    ## Callbacks ##
    before_validation :set_price
    after_create_commit :update_item_stock

    ## Validations ##
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :item, presence: true
    validates :price, presence: true
    validates :item_id, uniqueness: { scope: :order_id }



    
    private

    def set_price
        self.price = item.price * quantity
    end

    def update_item_stock
        _inventory_item = item.inventory_item
        _inventory_item.update(quantity: _inventory_item.quantity - quantity)
    end
end
