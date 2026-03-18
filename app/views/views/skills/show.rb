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
      end

      private

      def field(label, &block)
        div(class: "agent-form__field") do
          label(class: "agent-form__label") { label }
          yield
        end
      end
    end
  end
end
