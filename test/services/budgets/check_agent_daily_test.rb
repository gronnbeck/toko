# frozen_string_literal: true

require "test_helper"

module Budgets
  class CheckAgentDailyTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha", daily_budget_cents: 1000)
    end

    test "allowed when no tasks today" do
      result = Budgets::CheckAgentDaily.call(agent: @agent)
      assert result[:allowed]
      assert_equal 0, result[:spent_cents]
      assert_equal 1000, result[:limit_cents]
    end

    test "allowed when spend is below limit" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 400)
      result = Budgets::CheckAgentDaily.call(agent: @agent)
      assert result[:allowed]
      assert_equal 400, result[:spent_cents]
    end

    test "not allowed when spend reaches limit" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 1000)
      result = Budgets::CheckAgentDaily.call(agent: @agent)
      assert_not result[:allowed]
    end

    test "always allowed when no daily_budget_cents set" do
      agent = Agent.create!(name: "Bravo")
      Task.create!(title: "T1", status: :completed, claimed_by: agent, cost_cents: 99999)
      result = Budgets::CheckAgentDaily.call(agent: agent)
      assert result[:allowed]
      assert_nil result[:limit_cents]
    end

    test "ignores tasks without cost" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent)
      result = Budgets::CheckAgentDaily.call(agent: @agent)
      assert result[:allowed]
      assert_equal 0, result[:spent_cents]
    end

    test "includes failed tasks in spend" do
      Task.create!(title: "T1", status: :failed, claimed_by: @agent, cost_cents: 600)
      result = Budgets::CheckAgentDaily.call(agent: @agent)
      assert_equal 600, result[:spent_cents]
    end
  end
end
