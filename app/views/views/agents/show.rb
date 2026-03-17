# frozen_string_literal: true

module Views
  module Agents
    class Show < ApplicationView
      def initialize(agent:)
        @agent = agent
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/agents", class: "agent-show__back") { "← Agents" }
            h1(class: "home__title") { @agent.name }
            span(class: "status-pill status-pill--#{@agent.status}") { @agent.status }
          end

          render ::Components::AgentForm.new(agent: @agent)
        end
      end
    end
  end
end
