# frozen_string_literal: true

require "test_helper"

module Goals
  class ActivateTest < ActiveSupport::TestCase
    setup do
      @org = Organization.create!(name: "Acme")
      @goal = Goal.create!(title: "Ship v1", organization: @org)
    end

    test "activates a pending goal" do
      result = Goals::Activate.call(goal: @goal)

      assert_equal "active", result[:status]
      assert @goal.reload.active?
    end

    test "creates a planning task for the goal" do
      assert_difference "Task.count", 1 do
        Goals::Activate.call(goal: @goal)
      end

      task = @goal.tasks.last
      assert_equal "Plan goal: Ship v1", task.title
      assert task.pending?
      assert_equal @goal, task.goal
    end

    test "returns error when goal is not pending" do
      @goal.update!(status: :active)

      result = Goals::Activate.call(goal: @goal)

      assert_equal "Goal is not pending", result[:error]
    end
  end
end
