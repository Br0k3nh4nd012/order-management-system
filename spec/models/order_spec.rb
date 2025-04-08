require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:customer) { create(:customer) }
  let!(:item) { create(:item) }
  let!(:inventory_item) { create(:inventory_item, item: item, quantity: 10) }
  let!(:order) { build(:order, customer: customer) }
  
  describe 'callbacks' do
    context 'on create' do
      it 'sets default status to placed' do
        order.save
        expect(order.status).to eq('placed')
      end
    end

    context 'on status change' do
      it 'enqueues OrderStatusChangeJob' do
        ActiveJob::Base.queue_adapter = :test
        order.save
        expect {
          order.update_status('preparing')
        }.to have_enqueued_job(OrderStatusChangeJob)
      end
    end
  end

  describe '#update_status' do
    let!(:order) { create(:order, customer: customer) }
    let!(:order_item) { create(:order_item, order: order, item: item, quantity: 2) }

    context 'when status is cancelled' do
      it 'updates status to cancelled' do
        order.update_status(0)
        expect(order.status).to eq('cancelled')
      end

      it 'updates inventory' do
        expect {
          order.update_status(0)
        }.to change { inventory_item.reload.quantity }.by(2)
      end
    end

    context 'when status is other than cancelled' do
      it 'updates status to the provided value' do
        order.update_status('preparing')
        expect(order.status).to eq('preparing')
      end

      it 'does not update inventory' do
        expect {
          order.update_status('preparing')
        }.not_to change { inventory_item.reload.quantity }
      end
    end
  end

  describe '#notify_customer' do
    it 'enqueues email delivery' do
      ActiveJob::Base.queue_adapter = :test
      order.save
      expect {
        order.notify_customer
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end 