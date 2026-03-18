# frozen_string_literal: true

module Views
  module Agents
    class Show < ApplicationView
      def initialize(agent:, available_skills:)
        @agent = agent
        @available_skills = available_skills
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/agents", class: "agent-show__back") { "← Agents" }
            h1(class: "home__title") { @agent.name }
            span(class: "status-pill status-pill--#{@agent.display_status}") { @agent.display_status.to_s }
          end

          render ::Components::AgentForm.new(agent: @agent)
          render ::Components::AgentSkillsSection.new(agent: @agent, available_skills: @available_skills)
        end
      end
    end
  end
end
