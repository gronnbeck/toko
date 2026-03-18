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
end
