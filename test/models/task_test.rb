# frozen_string_literal: true

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "valid with title and status" do
    task = Task.new(title: "Fix bug", status: :pending)
    assert task.valid?
  end

  test "invalid without title" do
    task = Task.new(status: :pending)
    assert_not task.valid?
  end

  test "status defaults to pending" do
    task = Task.create!(title: "Fix bug")
    assert task.pending?
  end

  test "has expected statuses" do
    assert_equal %w[pending claimed started completed failed timed_out], Task.statuses.keys
  end

  test "optionally belongs to a goal" do
    org = Organization.create!(name: "Acme")
    goal = Goal.create!(title: "Ship v1", organization: org)
    task = Task.create!(title: "Fix bug", goal: goal)
    assert_equal goal, task.goal
  end

  test "valid without a goal" do
    task = Task.new(title: "Fix bug")
    assert task.valid?
  end

  test "cost_cents is nil by default" do
    task = Task.create!(title: "Fix bug")
    assert_nil task.cost_cents
  end

  test "cost_deducted_at is nil by default" do
    task = Task.create!(title: "Fix bug")
    assert_nil task.cost_deducted_at
  end
end
