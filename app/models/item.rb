class Item < ApplicationRecord
    ## Associations ##
    has_many :order_items
    has_one :inventory_item

    ## Validations ##
    validates :name, presence: true
    validates :price, presence: true
end
