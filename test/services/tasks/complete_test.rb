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

    test "promotes last message to result when no result exists" do
      @task.task_messages.create!(agent: @agent, body: "Progress")
      last = @task.task_messages.create!(agent: @agent, body: "Final output")

      Tasks::Complete.call(task: @task, agent: @agent)

      assert last.reload.result?
      assert_equal last, @task.result_message
    end

    test "does not overwrite existing result message" do
      result_msg = @task.task_messages.create!(agent: @agent, body: "Explicit result", kind: :result)
      @task.task_messages.create!(agent: @agent, body: "Later message")

      Tasks::Complete.call(task: @task, agent: @agent)

      assert_equal result_msg, @task.result_message
    end
  end
end
