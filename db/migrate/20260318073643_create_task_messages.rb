# frozen_string_literal: true

class CreateTaskMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :task_messages do |t|
      t.references :task, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :kind, default: 0, null: false
      t.timestamps
    end
  end
end
