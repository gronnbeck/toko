# frozen_string_literal: true

require "test_helper"

module Tasks
  class FailTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task  = Task.create!(title: "Fix bug", status: :started, claimed_by: @agent)
    end

    test "fails a task owned by the agent" do
      result = Tasks::Fail.call(task: @task, agent: @agent)

      assert_equal "failed", result[:status]
      assert @task.reload.failed?
    end

    test "fails a claimed task" do
      @task.update!(status: :claimed)

      result = Tasks::Fail.call(task: @task, agent: @agent)

      assert_equal "failed", result[:status]
    end

    test "returns error when agent does not own the task" do
      other = Agent.create!(name: "Bravo")

      result = Tasks::Fail.call(task: @task, agent: other)

      assert_equal "Agent does not own this task", result[:error]
    end
  end
end
