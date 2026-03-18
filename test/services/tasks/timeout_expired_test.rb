# frozen_string_literal: true

require "test_helper"

module Tasks
  class TimeoutExpiredTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
    end

    test "times out claimed tasks past their deadline" do
      task = Task.create!(title: "Stale", status: :claimed, claimed_by: @agent, timeout_at: 1.minute.ago)

      Tasks::TimeoutExpired.call

      assert task.reload.timed_out?
    end

    test "times out started tasks past their deadline" do
      task = Task.create!(title: "Stale", status: :started, claimed_by: @agent, timeout_at: 1.minute.ago)

      Tasks::TimeoutExpired.call

      assert task.reload.timed_out?
    end

    test "ignores tasks with future timeout" do
      task = Task.create!(title: "Active", status: :claimed, claimed_by: @agent, timeout_at: 1.hour.from_now)

      Tasks::TimeoutExpired.call

      assert task.reload.claimed?
    end

    test "ignores pending tasks" do
      task = Task.create!(title: "Pending", status: :pending)

      Tasks::TimeoutExpired.call

      assert task.reload.pending?
    end
  end
end
