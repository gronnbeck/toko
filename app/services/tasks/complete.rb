# frozen_string_literal: true

module Tasks
  module Complete
    module_function

    def call(task:, agent:)
      return { error: "Task is not started" } unless task.started?
      return { error: "Agent does not own this task" } unless task.claimed_by == agent

      task.update!(status: :completed)
      { status: "completed", task: task }
    end
  end
end
