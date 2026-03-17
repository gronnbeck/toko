# frozen_string_literal: true

module Components
  class OrganizationForm < ApplicationComponent
    def initialize(organization:)
      @organization = organization
    end

    def view_template
      form(action: "/organizations/#{@organization.id}", method: "post", class: "agent-form") do
        input name: "_method", type: "hidden", value: "patch"
        input name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token

        field("Name") do
          input(type: "text", name: "organization[name]", value: @organization.name, class: "agent-form__input")
        end

        field("Mission") do
          textarea(name: "organization[mission_body]", class: "agent-form__input agent-form__textarea") do
            @organization.mission&.body.to_s
          end
        end

        field("Policy") do
          textarea(name: "organization[policy_body]", class: "agent-form__input agent-form__textarea") do
            @organization.policy&.body.to_s
          end
        end

        div(class: "agent-form__actions") do
          button(type: "submit", class: "agent-form__btn") { "Save" }
        end
      end
    end

    private

    def field(label, &)
      div(class: "agent-form__field") do
        label(class: "agent-form__label") { label }
        yield
      end
    end
  end
end
