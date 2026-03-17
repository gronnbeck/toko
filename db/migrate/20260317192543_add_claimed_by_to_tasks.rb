class AddClaimedByToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :claimed_by, null: true, foreign_key: { to_table: :agents }
  end
end
