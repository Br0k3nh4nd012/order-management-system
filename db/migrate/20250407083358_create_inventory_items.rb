class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :quantity
      t.integer :threshold

      t.timestamps
    end
  end
end
