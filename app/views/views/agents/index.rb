# frozen_string_literal: true

module Views
  module Agents
    class Index < ApplicationView
      def initialize(agents:)
        @agents = agents
      end

      def view_template
        div(class: "home") do
          h1(class: "home__title") { "Agents" }
          if @agents.any?
            div(class: "task-grid") do
              @agents.each { |agent| render ::Components::AgentCard.new(agent:) }
            end
          else
            p(class: "home__empty") { "No agents yet." }
          end
        end
      end
    end
  end
end
