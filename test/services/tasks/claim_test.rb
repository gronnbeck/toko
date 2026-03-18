# frozen_string_literal: true

require "test_helper"

module Tasks
  class ClaimTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      @task  = Task.create!(title: "Fix bug", status: :pending)
    end

    test "claims a pending task" do
      result = Tasks::Claim.call(task: @task, agent: @agent)

      assert_equal "claimed", result[:status]
      assert @task.reload.claimed?
      assert_equal @agent, @task.claimed_by
      assert_in_delta 1.hour.from_now, @task.timeout_at, 2
    end

    test "returns error when task is not pending" do
      @task.update!(status: :claimed, claimed_by: @agent)

      result = Tasks::Claim.call(task: @task, agent: @agent)

      assert_equal "Task is not pending", result[:error]
    end
  end
end
