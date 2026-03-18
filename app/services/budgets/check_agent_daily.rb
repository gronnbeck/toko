# frozen_string_literal: true

module Budgets
  module CheckAgentDaily
    module_function

    def call(agent:)
      limit = agent.daily_budget_cents
      return { allowed: true, spent_cents: 0, limit_cents: nil } unless limit

      spent = spent_today(agent)
      { allowed: spent < limit, spent_cents: spent, limit_cents: limit }
    end

    def spent_today(agent)
      Task.where(claimed_by: agent, status: [ :completed, :failed ])
          .where(updated_at: Time.current.beginning_of_day..)
          .where.not(cost_cents: nil)
          .sum(:cost_cents)
    end

    private_class_method :spent_today
  end
end
