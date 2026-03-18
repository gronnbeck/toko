# frozen_string_literal: true

module Tasks
  module ReportCost
    module_function

    def call(task:, agent:, cost_cents:)
      return { error: "Agent does not own this task" } unless task.claimed_by == agent
      return { error: "Task is not completed or failed" } unless task.completed? || task.failed?
      return { error: "Cost already reported" } if task.cost_cents.present?

      task.update!(cost_cents: cost_cents)
      { status: "recorded", cost_cents: task.cost_cents }
    end
  end
end
