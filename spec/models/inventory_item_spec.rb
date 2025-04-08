require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  let!(:item) { create(:item) }
  let!(:inventory_item) { build(:inventory_item, item: item, quantity: 5, threshold: 3) }

  describe 'callbacks' do
    describe 'after_commit' do
      context 'when quantity is below threshold' do
        it 'sends low stock notification' do
          ActiveJob::Base.queue_adapter = :test
          inventory_item.quantity = 2
          expect {
            inventory_item.save
          }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end

      context 'when quantity is above threshold' do
        it 'does not send low stock notification' do
          ActiveJob::Base.queue_adapter = :test
          inventory_item.quantity = 4
          expect {
            inventory_item.save
          }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end
  end

  describe 'concurrent updates' do
    it 'handles concurrent quantity updates' do
      inventory_item.save
      
      # Simulate concurrent updates
      expect {
        inventory_item.with_lock do
          inventory_item.update!(quantity: inventory_item.quantity - 1)
        end
      }.to change { inventory_item.reload.quantity }.by(-1)
    end
  end
end 