require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let!(:customer) { create(:customer) }
  let!(:item) { create(:item, price: 10.0) }
  let!(:inventory_item) { create(:inventory_item, item: item, quantity: 10) }
  let!(:order) { create(:order, customer: customer) }
  let!(:order_item) { create(:order_item, order: order, item: item, quantity: 2) }

  describe 'GET #index' do
    before do
      order
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all orders' do
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['id']).to eq(order.id)
    end
  end

  describe 'GET #show' do
    before do
      order_item
      get :show, params: { id: order.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the order details' do
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(order.id)
      expect(json_response['items'].size).to eq(1)
      expect(json_response['items'].first['item_id']).to eq(item.id)
    end

    context 'when order does not exist' do
      before do
        get :show, params: { id: 999 }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        order: { customer_id: customer.id },
        items: [{ item_id: item.id, quantity: 2 }]
      }
    end

    context 'with valid parameters' do
      it 'creates a new order' do
        expect {
          post :create, params: valid_params
        }.to change(Order, :count).by(1)
      end

      it 'returns http created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created order' do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['customer_id']).to eq(customer.id)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          order: { customer_id: 999 },
          items: [{ item_id: item.id, quantity: 2 }]
        }
      end

      it 'does not create a new order' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Order, :count)
      end

      it 'returns http unprocessable entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid status' do
      before do
        patch :update, params: { id: order.id, order: { status: 'preparing' } }
      end

      it 'updates the order status' do
        expect(order.reload.status).to eq('preparing')
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when order is cancelled' do
      before do
        order.update(status: :cancelled)
        patch :update, params: { id: order.id, order: { status: 'preparing' } }
      end

      it 'does not update the status' do
        expect(order.reload.status).to eq('cancelled')
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when order does not exist' do
      before do
        patch :update, params: { id: 999, order: { status: 'preparing' } }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end 