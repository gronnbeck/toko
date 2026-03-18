# frozen_string_literal: true

module Budgets
  module DeductCosts
    module_function

    def call
      Budget.find_each { |budget| deduct_for(budget) }
    end

    def deduct_for(budget)
      tasks = undeducted_tasks(budget.organization)
      return if tasks.empty?

      total = tasks.sum(&:cost_cents)
      new_amount = [ budget.amount_cents - total, 0 ].max

      budget.update!(amount_cents: new_amount)
      tasks.each { |t| t.update!(cost_deducted_at: Time.current) }
    end

    def undeducted_tasks(org)
      agent_ids = org.agents.select(:id)
      Task.where(claimed_by_id: agent_ids)
          .where.not(cost_cents: nil)
          .where(cost_deducted_at: nil)
          .to_a
    end

    private_class_method :deduct_for, :undeducted_tasks
  end
end
