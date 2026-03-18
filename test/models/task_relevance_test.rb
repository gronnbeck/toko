# frozen_string_literal: true

require "test_helper"

class TaskRelevanceTest < ActiveSupport::TestCase
  setup do
    @agent = Agent.create!(name: "Alpha")
    @task  = Task.create!(title: "Fix bug")
  end

  test "valid with all attributes" do
    tr = TaskRelevance.new(task: @task, agent: @agent, relevant: true, mission_digest: "abc123")
    assert tr.valid?
  end

  test "invalid without mission_digest" do
    tr = TaskRelevance.new(task: @task, agent: @agent, relevant: false, mission_digest: nil)
    assert_not tr.valid?
  end

  test "unique per task and agent" do
    TaskRelevance.create!(task: @task, agent: @agent, relevant: true, mission_digest: "abc")

    duplicate = TaskRelevance.new(task: @task, agent: @agent, relevant: false, mission_digest: "def")
    assert_not duplicate.valid?
  end

  test "destroyed with task" do
    TaskRelevance.create!(task: @task, agent: @agent, relevant: true, mission_digest: "abc")
    assert_difference "TaskRelevance.count", -1 do
      @task.destroy
    end
  end

  test "destroyed with agent" do
    TaskRelevance.create!(task: @task, agent: @agent, relevant: true, mission_digest: "abc")
    assert_difference "TaskRelevance.count", -1 do
      @agent.destroy
    end
  end
end
