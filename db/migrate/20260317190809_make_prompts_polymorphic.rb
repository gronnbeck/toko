class MakePromptsPolymorphic < ActiveRecord::Migration[8.1]
  def change
    remove_reference :prompts, :agent, foreign_key: true
    add_reference :prompts, :promptable, polymorphic: true, null: false
    add_column :prompts, :kind, :integer, null: false, default: 0
  end
end
