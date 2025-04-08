class InventoryItem < ApplicationRecord
    ## Associations ##
    belongs_to :item

    ## Validations ##
    validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :item, presence: true, uniqueness: true
    
    ## Callbacks ##
    after_commit :notify_low_stock

    ## Instance Methods ##
    def notify_low_stock
        return if quantity >= threshold
        
        InventoryMailer.item_below_threshold(item).deliver_later
    end
end
