# frozen_string_literal: true

module Tasks
  module Complete
    module_function

    def call(task:, agent:)
      return { error: "Task is not started" } unless task.started?
      return { error: "Agent does not own this task" } unless task.claimed_by == agent

      promote_last_message(task)
      task.update!(status: :completed)
      { status: "completed", task: task }
    end

    def promote_last_message(task)
      return if task.result_message.present?

      last_msg = task.task_messages.order(created_at: :desc).first
      last_msg&.update!(kind: :result)
    end

    private_class_method :promote_last_message
  end
end
