# frozen_string_literal: true

module Views
  module Goals
    class Edit < ApplicationView
      def initialize(goal:)
        @goal = goal
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/goals/#{@goal.id}", class: "agent-show__back") { "← Back" }
            h1(class: "home__title") { "Edit Goal" }
          end

          render ::Components::GoalForm.new(goal: @goal, action: "/goals/#{@goal.id}", method: "patch")
        end
      end
    end
  end
end
