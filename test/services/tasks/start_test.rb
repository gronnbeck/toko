# frozen_string_literal: true

require "test_helper"

module Tasks
  class StartTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task  = Task.create!(title: "Fix bug", status: :claimed, claimed_by: @agent)
    end

    test "starts a claimed task" do
      result = Tasks::Start.call(task: @task, agent: @agent)

      assert_equal "started", result[:status]
      assert @task.reload.started?
    end

    test "returns error when task is not claimed" do
      @task.update!(status: :pending, claimed_by: nil)

      result = Tasks::Start.call(task: @task, agent: @agent)

      assert_equal "Task is not claimed", result[:error]
    end

    test "returns error when agent does not own the task" do
      other = Agent.create!(name: "Bravo")

      result = Tasks::Start.call(task: @task, agent: other)

      assert_equal "Agent does not own this task", result[:error]
    end
  end
end
