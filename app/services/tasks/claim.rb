# frozen_string_literal: true

module Tasks
  module Claim
    module_function

    def call(task:, agent:)
      return { error: "Task is not pending" } unless task.pending?

      task.update!(status: :claimed, claimed_by: agent, timeout_at: 1.hour.from_now)
      { status: "claimed", task: task }
    end
  end
end
