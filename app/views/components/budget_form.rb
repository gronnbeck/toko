# frozen_string_literal: true

module Components
  class BudgetForm < ApplicationComponent
    def initialize(organization:)
      @organization = organization
      @budget = organization.budget
    end

    def view_template
      div(class: "budget-section") do
        h2(class: "budget-section__heading") { "Budget" }

        if @budget
          div(class: "budget-section__summary") do
            span(class: "budget-section__amount") { format_cents(@budget.amount_cents) }
            span(class: "budget-section__currency") { @budget.currency }
          end
        end

        form(action: "/organizations/#{@organization.id}/budget", method: "post", class: "agent-form") do
          input(name: "_method", type: "hidden", value: "patch")
          input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)

          field("Amount (cents)") do
            input(
              type: "number",
              name: "budget[amount_cents]",
              value: @budget&.amount_cents.to_i,
              min: 0,
              class: "agent-form__input"
            )
          end

          div(class: "agent-form__actions") do
            button(type: "submit", class: "agent-form__btn") { "Update Budget" }
          end
        end
      end
    end

    private

    def field(label, &block)
      div(class: "agent-form__field") do
        label(class: "agent-form__label") { label }
        yield
      end
    end

    def format_cents(cents)
      "$#{"%.2f" % (cents / 100.0)}"
    end
  end
end
