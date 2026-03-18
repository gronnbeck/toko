# frozen_string_literal: true

require "test_helper"

module Budgets
  class DeductCostsTest < ActiveSupport::TestCase
    setup do
      @org = Organization.create!(name: "Acme")
      @budget = Budget.create!(organization: @org, amount_cents: 10_000)
      @agent = Agent.create!(name: "Alpha", organization: @org)
    end

    test "deducts un-deducted task costs from budget" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 300)
      Task.create!(title: "T2", status: :failed, claimed_by: @agent, cost_cents: 200)

      Budgets::DeductCosts.call

      assert_equal 9500, @budget.reload.amount_cents
    end

    test "marks tasks as deducted" do
      task = Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 300)

      Budgets::DeductCosts.call

      assert_not_nil task.reload.cost_deducted_at
    end

    test "skips already deducted tasks" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 300, cost_deducted_at: 1.hour.ago)

      Budgets::DeductCosts.call

      assert_equal 10_000, @budget.reload.amount_cents
    end

    test "floors budget at zero" do
      @budget.update!(amount_cents: 100)
      Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 500)

      Budgets::DeductCosts.call

      assert_equal 0, @budget.reload.amount_cents
    end

    test "skips tasks without cost" do
      Task.create!(title: "T1", status: :completed, claimed_by: @agent)

      Budgets::DeductCosts.call

      assert_equal 10_000, @budget.reload.amount_cents
    end
  end
end
