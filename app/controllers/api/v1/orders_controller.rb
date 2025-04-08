class Api::V1::OrdersController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_order, only: [:update, :show]
    before_action :validate_order_status, only: [:update]

    # GET /api/v1/orders
    def index
        hash = Order.all.includes(:order_items).map do |order|
                   {
                       id: order.id,
                       customer_id: order.customer_id,
                       status: order.status,
                       items: order.order_items.map do |item|
                           {
                               item_id: item.item_id,
                               quantity: item.quantity,
                               price: item.price
                           }
                       end
                   }
               end
        render json: hash, status: :ok
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /api/v1/orders
    # params: { order: { customer_id:, items: [{item_id:, quantity:}] } }
    def create
        params["order"]["items"] = params["items"]
        result = OrderCreationService.new(order_params).execute
        if result.success?
            render json: result.order, status: :created
        else
            render json: { error: result.error }, status: :unprocessable_entity
        end
        return
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    # PATCH /api/v1/orders/:id
    # params: { order: { status: } }
    def update
        @order.update_status(status_update_params[:status])
        render json: @order, status: :ok
    rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    def show
        hash = @order.as_json
        hash["items"] = @order.order_items.map do |item|
                            {
                                item_id: item.item_id,
                                quantity: item.quantity,
                                price: item.price
                            }
                        end
        render json: hash, status: :ok
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    # params = {"customer_id"=>1, "items"=>[{"item_id"=>2, "quantity"=>4}], "controller"=>"api/v1/orders", "action"=>"create", "order"=>{"customer_id"=>1}}
    def order_params
        params.require(:order).permit(:customer_id, items: [:item_id, :quantity])
    end

    def status_update_params
        params.require(:order).permit(:status)
    end

    def set_order
        @order = Order.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
    end

    def validate_order_status
        return unless @order.cancelled?

        render json: { error: "Order is in #{@order.status} status. Cannot update." }, status: :unprocessable_entity
    end
end