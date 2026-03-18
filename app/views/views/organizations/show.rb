# frozen_string_literal: true

module Views
  module Organizations
    class Show < ApplicationView
      def initialize(organization:)
        @organization = organization
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/organizations", class: "agent-show__back") { "← Organizations" }
            h1(class: "home__title") { @organization.name }
          end

          render ::Components::OrganizationForm.new(organization: @organization)
          render ::Components::BudgetForm.new(organization: @organization)
        end
      end
    end
  end
end
