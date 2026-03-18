# frozen_string_literal: true

class UpdateTaskStatuses < ActiveRecord::Migration[8.1]
  # Old: { pending: 0, in_progress: 1, completed: 2, failed: 3 }
  # New: { pending: 0, claimed: 1, started: 2, completed: 3, failed: 4, timed_out: 5 }

  def up
    # Order matters: remap from highest to lowest to avoid collisions
    execute "UPDATE tasks SET status = 4 WHERE status = 3" # failed 3 → 4
    execute "UPDATE tasks SET status = 3 WHERE status = 2" # completed 2 → 3
    # in_progress(1) stays at 1 (now "claimed")
  end

  def down
    execute "UPDATE tasks SET status = 2 WHERE status = 3" # completed 3 → 2
    execute "UPDATE tasks SET status = 3 WHERE status = 4" # failed 4 → 3
    # Remove started(2) and timed_out(5) rows would need manual handling
  end
end
