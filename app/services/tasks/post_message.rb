# frozen_string_literal: true

module Tasks
  module PostMessage
    module_function

    def call(task:, agent:, body:, kind: :message)
      return { error: "Agent does not own this task" } unless task.claimed_by == agent
      return { error: "Task is not active" } unless task.claimed? || task.started?

      message = task.task_messages.create!(agent: agent, body: body, kind: kind)
      { status: "created", message: message }
    end
  end
end
