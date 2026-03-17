class UpdateAgentStatuses < ActiveRecord::Migration[8.1]
  def change
    # Old: idle: 0, busy: 1, offline: 2
    # New: online: 0, busy: 1, missing: 2, offline: 3
    # Rename idle(0) -> online(0): no data change needed
    # Rename offline(2) -> offline(3): update existing rows
    execute "UPDATE agents SET status = 3 WHERE status = 2"

    # Default to offline(3) for new records
    change_column_default :agents, :status, 3
  end
end
