class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :buy_order, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.integer :quantity, null: false
      t.monetize :price, null: false, amount: { null: false, default: 0 }, currency: { present: false }

      t.timestamps
    end
  end
end
