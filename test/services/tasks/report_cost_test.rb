# frozen_string_literal: true

require "test_helper"

module Tasks
  class ReportCostTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task = Task.create!(title: "Fix bug", status: :completed, claimed_by: @agent)
    end

    test "records cost on completed task" do
      result = Tasks::ReportCost.call(task: @task, agent: @agent, cost_cents: 500)
      assert_equal "recorded", result[:status]
      assert_equal 500, @task.reload.cost_cents
    end

    test "records cost on failed task" do
      @task.update!(status: :failed)
      result = Tasks::ReportCost.call(task: @task, agent: @agent, cost_cents: 200)
      assert_equal "recorded", result[:status]
    end

    test "rejects if agent does not own task" do
      other = Agent.create!(name: "Bravo")
      result = Tasks::ReportCost.call(task: @task, agent: other, cost_cents: 500)
      assert_equal "Agent does not own this task", result[:error]
    end

    test "rejects if task is not completed or failed" do
      task = Task.create!(title: "New", status: :started, claimed_by: @agent)
      result = Tasks::ReportCost.call(task: task, agent: @agent, cost_cents: 500)
      assert_equal "Task is not completed or failed", result[:error]
    end

    test "rejects if cost already reported" do
      @task.update!(cost_cents: 100)
      result = Tasks::ReportCost.call(task: @task, agent: @agent, cost_cents: 500)
      assert_equal "Cost already reported", result[:error]
    end
  end
end
