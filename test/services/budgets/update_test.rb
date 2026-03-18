# frozen_string_literal: true

require "test_helper"

module Budgets
  class UpdateTest < ActiveSupport::TestCase
    setup do
      @org = Organization.create!(name: "Acme")
    end

    test "creates budget if none exists" do
      result = Budgets::Update.call(organization: @org, amount_cents: 5000)
      assert result
      assert_equal 5000, @org.reload.budget.amount_cents
    end

    test "updates existing budget" do
      Budget.create!(organization: @org, amount_cents: 1000)
      result = Budgets::Update.call(organization: @org, amount_cents: 8000)
      assert result
      assert_equal 8000, @org.reload.budget.amount_cents
    end

    test "rejects negative amount" do
      result = Budgets::Update.call(organization: @org, amount_cents: -1)
      assert_not result
    end
  end
end
