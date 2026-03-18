# frozen_string_literal: true

require "test_helper"

class TaskMessageTest < ActiveSupport::TestCase
  setup do
    @agent = Agent.create!(name: "Alpha")
    @task  = Task.create!(title: "Fix bug", status: :started, claimed_by: @agent)
  end

  test "valid with body, task, and agent" do
    msg = TaskMessage.new(body: "Working on it", task: @task, agent: @agent)
    assert msg.valid?
  end

  test "invalid without body" do
    msg = TaskMessage.new(task: @task, agent: @agent)
    assert_not msg.valid?
  end

  test "has expected kinds" do
    assert_equal %w[message result], TaskMessage.kinds.keys
  end

  test "defaults to message kind" do
    msg = TaskMessage.create!(body: "Progress", task: @task, agent: @agent)
    assert msg.message?
  end

  test "destroyed with task" do
    TaskMessage.create!(body: "Log", task: @task, agent: @agent)
    assert_difference "TaskMessage.count", -1 do
      @task.destroy
    end
  end
end
