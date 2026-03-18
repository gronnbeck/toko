# frozen_string_literal: true

require "test_helper"

module Tasks
  class CompleteTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task  = Task.create!(title: "Fix bug", status: :started, claimed_by: @agent)
    end

    test "completes a started task" do
      result = Tasks::Complete.call(task: @task, agent: @agent)

      assert_equal "completed", result[:status]
      assert @task.reload.completed?
    end

    test "returns error when task is not started" do
      @task.update!(status: :claimed)

      result = Tasks::Complete.call(task: @task, agent: @agent)

      assert_equal "Task is not started", result[:error]
    end

    test "returns error when agent does not own the task" do
      other = Agent.create!(name: "Bravo")

      result = Tasks::Complete.call(task: @task, agent: other)

      assert_equal "Agent does not own this task", result[:error]
    end
  end
end
