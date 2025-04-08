class OrderCreationService
  attr_reader :order, :error

  def initialize(params)
    @params = params
    @order = nil
    @error = nil
    @customer = nil
  end

  def execute
    puts @params
    validate_items
    validate_customer
    return self if @error.present?

    ActiveRecord::Base.transaction do
      # Lock the items to prevent concurrent modifications
      lock_items
      
      # Validate item availability
      validate_item_availability
      return self if @error.present?

      create_order
      create_order_items
      update_total_price
    end
    self
  rescue ActiveRecord::RecordInvalid => e
    @error = e.message
    self
  rescue ActiveRecord::StaleObjectError => e
    @error = "Order could not be processed due to concurrent modification. Please try again."
    self
  rescue StandardError => e
    @error = "Failed to create order: #{e.message}"
    self
  end

  def success?
    @error.nil?
  end

  private

  def validate_items
    return if @params[:items].blank?
    
    @params[:items].each do |item|
      unless item[:item_id].present? && item[:quantity].present? && item[:quantity].to_i > 0
        @error = "Invalid item data: Each item must have a valid item_id and positive quantity"
        return
      end
    end
  end

  def lock_items
    item_ids = @params[:items].map { |item| item[:item_id] }
    InventoryItem.lock.where(item_id: item_ids).to_a
  end

  def validate_item_availability
    @params[:items].each do |item|
      item_record = InventoryItem.find(item[:item_id])
      if item_record.quantity < item[:quantity].to_i
        @error = "Insufficient stock for item #{item_record.item.name}"
        return
      end
    end
  end

  def create_order
    @order = @customer.orders.create!
  end

  def create_order_items
    raise "No items to create" if @params[:items].blank?

    @params[:items].each do |item_params|
      @order.order_items.create!(
        item_id: item_params[:item_id],
        quantity: item_params[:quantity]
      )
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    @error = "Failed to create order items: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def update_total_price
    @order.total_price = @order.order_items.sum(:price)
    @order.save!
  end 
  def validate_customer
    @customer = Customer.find(@params[:customer_id])
  end
end