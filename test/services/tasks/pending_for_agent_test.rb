# frozen_string_literal: true

require "test_helper"

module Tasks
  class PendingForAgentTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      Prompt.create!(body: "Run tests.", promptable: @agent, kind: :mission)
      @task1 = Task.create!(title: "Task 1")
      @task2 = Task.create!(title: "Task 2")
    end

    test "returns all pending tasks when no relevance records" do
      tasks = Tasks::PendingForAgent.call(agent: @agent)

      assert_includes tasks, @task1
      assert_includes tasks, @task2
    end

    test "excludes tasks marked irrelevant with current mission digest" do
      TaskRelevance.create!(
        task: @task1, agent: @agent, relevant: false,
        mission_digest: @agent.mission_digest
      )

      tasks = Tasks::PendingForAgent.call(agent: @agent)

      assert_not_includes tasks, @task1
      assert_includes tasks, @task2
    end

    test "includes tasks marked irrelevant with stale digest" do
      TaskRelevance.create!(
        task: @task1, agent: @agent, relevant: false,
        mission_digest: "stale_digest"
      )

      tasks = Tasks::PendingForAgent.call(agent: @agent)

      assert_includes tasks, @task1
    end

    test "includes tasks marked relevant" do
      TaskRelevance.create!(
        task: @task1, agent: @agent, relevant: true,
        mission_digest: @agent.mission_digest
      )

      tasks = Tasks::PendingForAgent.call(agent: @agent)

      assert_includes tasks, @task1
    end

    test "returns all pending tasks when agent has no mission" do
      agent = Agent.create!(name: "Bravo")
      tasks = Tasks::PendingForAgent.call(agent: agent)

      assert_includes tasks, @task1
      assert_includes tasks, @task2
    end
  end
end
