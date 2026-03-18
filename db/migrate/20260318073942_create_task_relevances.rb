# frozen_string_literal: true

class CreateTaskRelevances < ActiveRecord::Migration[8.1]
  def change
    create_table :task_relevances do |t|
      t.references :task, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.boolean :relevant, null: false
      t.string :mission_digest, null: false
      t.timestamps
    end

    add_index :task_relevances, [ :task_id, :agent_id ], unique: true
  end
end
