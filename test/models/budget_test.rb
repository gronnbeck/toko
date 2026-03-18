# frozen_string_literal: true

require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(name: "Acme")
  end

  test "valid with organization and defaults" do
    budget = Budget.new(organization: @org)
    assert budget.valid?
  end

  test "amount_cents defaults to 0" do
    budget = Budget.create!(organization: @org)
    assert_equal 0, budget.amount_cents
  end

  test "currency defaults to USD" do
    budget = Budget.create!(organization: @org)
    assert_equal "USD", budget.currency
  end

  test "invalid with negative amount_cents" do
    budget = Budget.new(organization: @org, amount_cents: -1)
    assert_not budget.valid?
  end

  test "belongs to organization" do
    budget = Budget.create!(organization: @org)
    assert_equal @org, budget.organization
  end
end
