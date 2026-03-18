# frozen_string_literal: true

module Views
  module Goals
    class New < ApplicationView
      def initialize(goal:, organizations:)
        @goal = goal
        @organizations = organizations
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/goals", class: "agent-show__back") { "← Goals" }
            h1(class: "home__title") { "New Goal" }
          end

          render ::Components::GoalForm.new(goal: @goal, action: "/goals", organizations: @organizations)
        end
      end
    end
  end
end
