class CreatePrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :prompts do |t|
      t.text :body, null: false
      t.references :agent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
