# frozen_string_literal: true

module Components
  class AgentForm < ApplicationComponent
    def initialize(agent:)
      @agent = agent
    end

    def view_template
      form(action: "/agents/#{@agent.id}", method: "post", class: "agent-form") do
        input name: "_method", type: "hidden", value: "patch"
        input name: authenticity_token_field, type: "hidden", value: helpers.form_authenticity_token

        field("Name") do
          input(
            type: "text", name: "agent[name]",
            value: @agent.name, class: "agent-form__input"
          )
        end

        field("Status") do
          select(name: "agent[status]", class: "agent-form__input") do
            Agent.statuses.each_key do |s|
              if s == @agent.status
                option(value: s, selected: true) { s }
              else
                option(value: s) { s }
              end
            end
          end
        end

        field("Description") do
          textarea(name: "agent[description]", class: "agent-form__input agent-form__textarea") do
            @agent.description.to_s
          end
        end

        div(class: "agent-form__actions") do
          button(type: "submit", class: "agent-form__btn") { "Save" }
        end
      end
    end

    private

    def field(label, &block)
      div(class: "agent-form__field") do
        label(class: "agent-form__label") { label }
        yield
      end
    end

    def authenticity_token_field = "authenticity_token"
  end
end
