class AddTokenAndLastSeenAtToAgents < ActiveRecord::Migration[8.1]
  def up
    add_column :agents, :token, :string
    add_column :agents, :last_seen_at, :datetime

    Agent.find_each { |a| a.update_columns(token: SecureRandom.uuid) }

    change_column_null :agents, :token, false
    add_index :agents, :token, unique: true
  end

  def down
    remove_index :agents, :token
    remove_column :agents, :token
    remove_column :agents, :last_seen_at
  end
end
