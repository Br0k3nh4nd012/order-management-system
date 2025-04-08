ActiveAdmin.register Order do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :status, :customer_id, :total_price
  #
  # or
  #
  # permit_params do
  #   permitted = [:status, :customer_id, :total_price]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  show do
    attributes_table do
      row :id
      row :status
      row :customer
      row :total_price
      row :created_at
      row :updated_at
    end

    panel "Order Items" do
      table_for order.order_items do
        column :item
        column :quantity
        column :price
      end
    end
  end
end
