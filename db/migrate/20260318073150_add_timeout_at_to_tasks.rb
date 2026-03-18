class AddTimeoutAtToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :timeout_at, :datetime
  end
end
