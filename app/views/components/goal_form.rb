# frozen_string_literal: true

module Components
  class GoalForm < ApplicationComponent
    def initialize(goal:, action:, method: "post", organizations: nil)
      @goal = goal
      @action = action
      @method = method
      @organizations = organizations
    end

    def view_template
      form(action: @action, method: "post", class: "agent-form") do
        input(name: "_method", type: "hidden", value: @method) unless @method == "post"
        input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)

        org_select if @organizations

        field("Title") do
          input(type: "text", name: "goal[title]", value: @goal.title.to_s, class: "agent-form__input")
        end

        field("Description") do
          textarea(name: "goal[description]", class: "agent-form__input agent-form__textarea") do
            @goal.description.to_s
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

    def org_select
      field("Organization") do
        select(name: "goal[organization_id]", class: "agent-form__input") do
          @organizations.each do |org|
            if org.id == @goal.organization_id
              option(value: org.id, selected: true) { org.name }
            else
              option(value: org.id) { org.name }
            end
          end
        end
      end
    end
  end
end
