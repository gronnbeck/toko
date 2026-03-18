# frozen_string_literal: true

module Components
  class GoalCard < ApplicationComponent
    def initialize(goal:)
      @goal = goal
    end

    def view_template
      a(href: "/goals/#{@goal.id}", class: "agent-card") do
        div(class: "goal-card__content") do
          span(class: "agent-card__name") { @goal.title }
          span(class: "goal-card__org") { @goal.organization.name }
        end
        span(class: "status-pill status-pill--#{@goal.status}") { @goal.status }
      end
    end
  end
end
