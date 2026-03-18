# frozen_string_literal: true

module Views
  module Goals
    class Index < ApplicationView
      def initialize(goals:)
        @goals = goals
      end

      def view_template
        div(class: "home") do
          header(class: "goals-header") do
            h1(class: "home__title") { "Goals" }
            a(href: "/goals/new", class: "agent-form__btn") { "New Goal" }
          end

          if @goals.any?
            div(class: "task-grid") do
              @goals.each { |goal| render ::Components::GoalCard.new(goal:) }
            end
          else
            p(class: "home__empty") { "No goals yet." }
          end
        end
      end
    end
  end
end
