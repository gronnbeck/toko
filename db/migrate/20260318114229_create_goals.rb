# frozen_string_literal: true

class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
