# frozen_string_literal: true

class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :amount_cents, default: 0, null: false
      t.string :currency, default: "USD", null: false

      t.timestamps
    end
  end
end
