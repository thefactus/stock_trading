class CreateBuyOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :buy_orders do |t|
      t.references :business, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.integer :quantity, null: false
      t.monetize :price, null: false, amount: { null: false, default: 0 }, currency: { present: false }
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
