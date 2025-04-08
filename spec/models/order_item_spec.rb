require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let!(:order) { create(:order) }
  let!(:item) { create(:item, price: 10.0) }
  let!(:inventory_item) { create(:inventory_item, item: item, quantity: 10, threshold: 5) }
  let!(:order_item) { build(:order_item, order: order, item: item, quantity: 2) }

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets price based on item price and quantity' do
        order_item.save
        expect(order_item.price).to eq(20.0) # 10.0 * 2
      end
    end

    describe 'after_create_commit' do
      it 'updates item stock' do
        expect {
          order_item.save
        }.to change { inventory_item.reload.quantity }.by(-2)
      end

      context 'when inventory update fails' do
        before do
          allow_any_instance_of(InventoryItem).to receive(:update).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'raises an error' do
          expect {
            order_item.save!
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  describe 'concurrent updates' do
    it 'handles concurrent inventory updates' do
      order_item.save
      inventory_item.reload

      # Simulate concurrent update
      expect {
        inventory_item.with_lock do
          inventory_item.update!(quantity: inventory_item.quantity - 1)
        end
      }.to change { inventory_item.reload.quantity }.by(-1)
    end
  end
end 