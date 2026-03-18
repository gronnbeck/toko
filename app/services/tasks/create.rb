# frozen_string_literal: true

module Tasks
  module Create
    module_function

    def call(goal:, title:, description: nil, agent:)
      task = Task.new(goal: goal, title: title, description: description)

      unless authorized?(agent, goal)
        task.errors.add(:base, "Agent organization does not match goal organization")
        return task
      end

      task.save
      task
    end

    def authorized?(agent, goal)
      agent.organization_id == goal.organization_id
    end

    private_class_method :authorized?
  end
end
