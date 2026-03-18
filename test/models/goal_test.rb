# frozen_string_literal: true

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(name: "Acme")
  end

  test "valid with title and organization" do
    goal = Goal.new(title: "Ship v1", organization: @org)
    assert goal.valid?
  end

  test "invalid without title" do
    goal = Goal.new(organization: @org)
    assert_not goal.valid?
  end

  test "status defaults to pending" do
    goal = Goal.create!(title: "Ship v1", organization: @org)
    assert goal.pending?
  end

  test "has expected statuses" do
    assert_equal %w[pending active review completed], Goal.statuses.keys
  end

  test "belongs to organization" do
    goal = Goal.create!(title: "Ship v1", organization: @org)
    assert_equal @org, goal.organization
  end

  test "has many tasks" do
    goal = Goal.create!(title: "Ship v1", organization: @org)
    task = Task.create!(title: "Fix bug", goal: goal)
    assert_includes goal.tasks, task
  end

  test "nullifies tasks on destroy" do
    goal = Goal.create!(title: "Ship v1", organization: @org)
    task = Task.create!(title: "Fix bug", goal: goal)
    goal.destroy
    assert_nil task.reload.goal_id
  end
end
