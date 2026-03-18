class AddCostTrackingToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :cost_cents, :integer
    add_column :tasks, :cost_deducted_at, :datetime
  end
end
