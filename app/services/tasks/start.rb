# frozen_string_literal: true

module Tasks
  module Start
    module_function

    def call(task:, agent:)
      return { error: "Task is not claimed" } unless task.claimed?
      return { error: "Agent does not own this task" } unless task.claimed_by == agent

      task.update!(status: :started)
      { status: "started", task: task }
    end
  end
end
