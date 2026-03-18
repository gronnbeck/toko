module Views
  module Skills
    class Show < ApplicationView
      def initialize(skill:)
        @skill = skill
      end

      def view_template
        div(class: "home") do
          header(class: "agent-show__header") do
            a(href: "/agents", class: "agent-show__back") { "← Agents" }
            h1(class: "home__title") { @skill.name }
          end

          edit_form
          used_by_section
          delete_section
        end
      end

      private

      def edit_form
        form(action: "/skills/#{@skill.id}", method: "post", class: "agent-form") do
          input(name: "_method", type: "hidden", value: "patch")
          input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
          field("Name") { input(type: "text", name: "skill[name]", value: @skill.name, class: "agent-form__input") }
          field("Keywords") { input(type: "text", name: "skill[keywords]", value: @skill.keywords.to_s, class: "agent-form__input") }
          field("Description") { input(type: "text", name: "skill[description]", value: @skill.description.to_s, class: "agent-form__input") }
          field("Prompt") { textarea(name: "skill[prompt_body]", class: "agent-form__input agent-form__textarea") { @skill.prompt&.body.to_s } }
          div(class: "agent-form__actions") { button(type: "submit", class: "agent-form__btn") { "Save" } }
        end
      end

      def used_by_section
        agents = @skill.agents
        return if agents.empty?

        div(class: "skills-section", style: "margin-top: 24px;") do
          h3(class: "agent-form__label") { "Used by" }
          div(class: "skills-section__list") do
            agents.each do |agent|
              a(href: "/agents/#{agent.id}", class: "skills-section__name") { agent.name }
            end
          end
        end
      end

      def delete_section
        div(style: "margin-top: 24px; max-width: 560px;") do
          form(action: "/skills/#{@skill.id}", method: "post") do
            input(name: "_method", type: "hidden", value: "delete")
            input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
            button(type: "submit", class: "skills-section__remove-btn", data: { turbo_confirm: "Delete this skill?" }) { "Delete Skill" }
          end
        end
      end

      def field(label, &block)
        div(class: "agent-form__field") do
          label(class: "agent-form__label") { label }
          yield
        end
      end
    end
  end
end
