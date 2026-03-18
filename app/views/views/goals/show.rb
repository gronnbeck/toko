# frozen_string_literal: true

module Views
  module Goals
    class Show < ApplicationView
      TRANSITIONS = {
        "pending"   => [ "active" ],
        "active"    => [ "review", "completed" ],
        "review"    => [ "active", "completed" ],
        "completed" => []
      }.freeze

      def initialize(goal:)
        @goal = goal
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/goals", class: "agent-show__back") { "← Goals" }
            h1(class: "home__title") { @goal.title }
            span(class: "status-pill status-pill--#{@goal.status}") { @goal.status }
          end

          description_section
          transition_buttons
          tasks_section
          actions_bar
        end
      end

      private

      def description_section
        return unless @goal.description.present?

        div(class: "goal-detail") do
          p(class: "goal-detail__desc") { @goal.description }
        end
      end

      def transition_buttons
        next_statuses = TRANSITIONS.fetch(@goal.status, [])
        return if next_statuses.empty?

        div(class: "goal-transitions") do
          next_statuses.each do |status|
            form(action: "/goals/#{@goal.id}/transition", method: "post", style: "display:inline") do
              input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
              input(name: "status", type: "hidden", value: status)
              button(type: "submit", class: "agent-form__btn goal-transitions__btn") { "Mark #{status}" }
            end
          end
        end
      end

      def tasks_section
        tasks = @goal.tasks
        return if tasks.empty?

        div(class: "goal-tasks") do
          h2(class: "goal-tasks__heading") { "Tasks" }
          tasks.each { |task| render ::Components::TaskCard.new(task:) }
        end
      end

      def actions_bar
        div(class: "goal-actions") do
          a(href: "/goals/#{@goal.id}/edit", class: "agent-form__btn") { "Edit" }
          form(action: "/goals/#{@goal.id}", method: "post", style: "display:inline") do
            input(name: "_method", type: "hidden", value: "delete")
            input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
            button(type: "submit", class: "agent-form__btn goal-actions__delete") { "Delete" }
          end
        end
      end
    end
  end
end
