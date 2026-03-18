class AddDailyBudgetCentsToAgents < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :daily_budget_cents, :integer
  end
end
