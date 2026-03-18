# frozen_string_literal: true

require "test_helper"

module Tasks
  class PostMessageTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task  = Task.create!(title: "Fix bug", status: :started, claimed_by: @agent)
    end

    test "posts a message on an active task" do
      result = Tasks::PostMessage.call(task: @task, agent: @agent, body: "Working on it")

      assert_equal "created", result[:status]
      assert result[:message].message?
    end

    test "posts a result message" do
      result = Tasks::PostMessage.call(task: @task, agent: @agent, body: "Done", kind: :result)

      assert result[:message].result?
    end

    test "works on claimed tasks" do
      @task.update!(status: :claimed)

      result = Tasks::PostMessage.call(task: @task, agent: @agent, body: "Starting")

      assert_equal "created", result[:status]
    end

    test "returns error when agent does not own the task" do
      other = Agent.create!(name: "Bravo")

      result = Tasks::PostMessage.call(task: @task, agent: other, body: "Hi")

      assert_equal "Agent does not own this task", result[:error]
    end

    test "returns error when task is not active" do
      @task.update!(status: :completed)

      result = Tasks::PostMessage.call(task: @task, agent: @agent, body: "Late")

      assert_equal "Task is not active", result[:error]
    end
  end
end
