class InventoryItem < ApplicationRecord
    ## Associations ##
    belongs_to :item

    ## Validations ##
    validates :quantity, presence: true
    validates :item, presence: true, uniqueness: true
    
    ## Callbacks ##
    after_commit :notify_low_stock

    ## Instance Methods ##
    def notify_low_stock
        if quantity < threshold
            puts "Low stock alert: #{item.name} has only #{quantity} left"
        end
    end
end
