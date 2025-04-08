require 'rails_helper'

RSpec.describe OrderCreationService do
  let!(:customer) { create(:customer) }
  let!(:item1) { create(:item, price: 10.0) }
  let!(:item2) { create(:item, price: 20.0) }
  let!(:inventory_item1) { create(:inventory_item, item: item1, quantity: 10) }
  let!(:inventory_item2) { create(:inventory_item, item: item2, quantity: 5) }
  
  let!(:params) do
    {
      customer_id: customer.id,
      items: [
        { item_id: item1.id, quantity: 2 },
        { item_id: item2.id, quantity: 1 }
      ]
    }
  end

  subject { described_class.new(params) }

  describe '#execute' do
    context 'with valid parameters' do
      it 'creates an order' do
        expect {
          subject.execute
        }.to change(Order, :count).by(1)
      end

      it 'creates order items' do
        expect {
          subject.execute
        }.to change(OrderItem, :count).by(2)
      end

      it 'updates inventory' do
        subject.execute
        expect(inventory_item1.reload.quantity).to eq(8)
        expect(inventory_item2.reload.quantity).to eq(4)
      end

      it 'sets correct prices' do
        subject.execute
        order = subject.order
        expect(order.order_items.first.price).to eq(20.0) # 10.0 * 2
        expect(order.order_items.second.price).to eq(20.0) # 20.0 * 1
      end

      it 'returns success' do
        expect(subject.execute.success?).to be true
      end
    end

    context 'with invalid parameters' do
      context 'when customer does not exist' do
        let(:params) { super().merge(customer_id: 999) }

        it 'returns error' do
          expect(subject.execute.success?).to be false
          expect(subject.error).to include("Couldn't find Customer")
        end
      end

      context 'when item does not exist' do
        let(:params) do
          super().merge(items: [{ item_id: 999, quantity: 1 }])
        end

        it 'returns error' do
          expect(subject.execute.success?).to be false
          expect(subject.error).to include("Couldn't find InventoryItem")
        end
      end

      context 'when quantity is invalid' do
        let(:params) do
          super().merge(items: [{ item_id: item1.id, quantity: 0 }])
        end

        it 'returns error' do
          expect(subject.execute.success?).to be false
          expect(subject.error).to include("Each item must have a valid item_id and positive quantity")
        end
      end

      context 'when insufficient stock' do
        let(:params) do
          super().merge(items: [{ item_id: item1.id, quantity: 20 }])
        end

        it 'returns error' do
          expect(subject.execute.success?).to be false
          expect(subject.error).to include("Insufficient stock")
        end
      end
    end

    context 'with concurrent updates' do
      it 'handles concurrent inventory updates' do
        params1 = {
          customer_id: customer.id,
          items: [
            { item_id: item1.id, quantity: 8 },
            { item_id: item2.id, quantity: 1 }
          ]
        }
        params2 = {
          customer_id: customer.id,
          items: [
            { item_id: item1.id, quantity: 5 },
            { item_id: item2.id, quantity: 2 }
          ]
        }
        service1 = described_class.new(params1)
        service2 = described_class.new(params2)

        thread1 = Thread.new { service1.execute }
        thread2 = Thread.new { service2.execute }

        # Wait for both threads to complete
        result1 = thread1.value
        result2 = thread2.value

        # One of the services should succeed and one should fail
        expect([result1.success?, result2.success?]).to contain_exactly(true, false)
        
        failed_result = result1.success? ? result2 : result1
        expect(failed_result.error).to include("Insufficient stock")
      end
    end
  end
end 