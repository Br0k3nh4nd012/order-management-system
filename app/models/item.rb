class Item < ApplicationRecord
    ## Associations ##
    has_many :order_items, dependent: :destroy
    has_one :inventory_item, dependent: :destroy

    ## Validations ##
    validates :name, presence: true
    validates :price, presence: true
end
