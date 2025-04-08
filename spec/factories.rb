FactoryBot.define do
  # Customer Factory
  factory :customer do
    sequence(:email) { |n| "customer#{n}@example.com" }
    sequence(:name) { |n| "Customer #{n}" }
  end

  # Item Factory
  factory :item do
    sequence(:name) { |n| "Item #{n}" }
    price { 10.0 }
  end

  # InventoryItem Factory
  factory :inventory_item do
    association :item
    quantity { 10 }
    threshold { 5 }
  end

  # Order Factory
  factory :order do
    association :customer
    status { :placed }

    trait :cancelled do
      status { :cancelled }
    end

    trait :preparing do
      status { :preparing }
    end

    trait :out_for_delivery do
      status { :out_for_delivery }
    end

    trait :delivered do
      status { :delivered }
    end
  end

  # OrderItem Factory
  factory :order_item do
    association :order
    association :item
    quantity { 1 }
    price { 10.0 }

    trait :with_quantity do
      quantity { 2 }
    end

    trait :with_price do
      price { 20.0 }
    end
  end
end 