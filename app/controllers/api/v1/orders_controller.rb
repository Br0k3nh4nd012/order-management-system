class Api::V1::OrdersController
    # POST /api/v1/orders
    # params: { order: { customer_id:, item_id: } }
    def create
        order = Order.create!(order_params)
        render json: order, status: :created
    end

    private

    def order_params
        params.require(:order).permit(:customer_id, :item_id)
    end
end