# frozen_string_literal: true

module Tasks
  module Fail
    module_function

    def call(task:, agent:)
      return { error: "Agent does not own this task" } unless task.claimed_by == agent

      task.update!(status: :failed)
      { status: "failed", task: task }
    end
  end
end
