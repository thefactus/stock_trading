class CreateBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.integer :total_shares, null: false
      t.integer :available_shares, null: false

      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
