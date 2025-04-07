class Order < ApplicationRecord
    ## Associations ##
    has_many :order_items
    belongs_to :customer

    
    enum :status, %i[placed preparing out_for_delivery delivered]
end
