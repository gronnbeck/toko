# frozen_string_literal: true

module Goals
  module Activate
    module_function

    def call(goal:)
      return { error: "Goal is not pending" } unless goal.pending?

      goal.update!(status: :active)
      create_planning_task(goal)
      { status: "active", goal: goal }
    end

    def create_planning_task(goal)
      Task.create!(title: "Plan goal: #{goal.title}", goal: goal)
    end

    private_class_method :create_planning_task
  end
end
