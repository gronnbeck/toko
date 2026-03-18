# frozen_string_literal: true

module Budgets
  module Update
    module_function

    def call(organization:, amount_cents:)
      budget = organization.budget || organization.build_budget
      budget.update(amount_cents: amount_cents.to_i)
    end
  end
end
