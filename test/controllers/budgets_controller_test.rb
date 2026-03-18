# frozen_string_literal: true

require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org = Organization.create!(name: "Acme")
  end

  test "PATCH update creates budget if none exists" do
    patch organization_budget_path(@org), params: { budget: { amount_cents: 5000 } }
    assert_redirected_to organization_path(@org)
    assert_equal 5000, @org.reload.budget.amount_cents
  end

  test "PATCH update changes existing budget" do
    Budget.create!(organization: @org, amount_cents: 1000)
    patch organization_budget_path(@org), params: { budget: { amount_cents: 8000 } }
    assert_redirected_to organization_path(@org)
    assert_equal 8000, @org.reload.budget.amount_cents
  end

  test "PATCH update with invalid amount re-renders org show" do
    patch organization_budget_path(@org), params: { budget: { amount_cents: -1 } }
    assert_response :unprocessable_entity
  end
end
