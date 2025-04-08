class InventoryMailer < ApplicationMailer

    def item_below_threshold(item)
        @item = item
        @inventory_item = item.inventory_item
        mail(to: "admin@example.com", subject: "Item Below Threshold")
    end
end