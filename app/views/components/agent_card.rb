# frozen_string_literal: true

module Components
  class AgentCard < ApplicationComponent
    def initialize(agent:)
      @agent = agent
    end

    def view_template
      a(href: "/agents/#{@agent.id}", class: "agent-card") do
        span(class: "agent-card__name") { @agent.name }
        span(class: "status-pill status-pill--#{@agent.status}") { @agent.status }
      end
    end
  end
end
