module Components
  class AgentSkillsForms < ApplicationComponent
    def initialize(agent:, available_skills:)
      @agent = agent
      @available_skills = available_skills
    end

    def view_template
      assign_form if @available_skills.any?
      new_skill_form
    end

    private

    def assign_form
      form(action: "/agents/#{@agent.id}/agent_skills", method: "post", class: "skills-section__assign") do
        input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
        select(name: "skill_id", class: "agent-form__input skills-section__select") do
          option(value: "") { "— Select a skill —" }
          @available_skills.each { |s| option(value: s.id) { s.name } }
        end
        button(type: "submit", class: "agent-form__btn") { "Assign" }
      end
    end

    def new_skill_form
      details(class: "skills-section__new") do
        summary(class: "skills-section__toggle") { "+ New Skill" }
        form(action: "/agents/#{@agent.id}/agent_skills", method: "post", class: "agent-form skills-section__new-form") do
          input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
          field("Name") { input(type: "text", name: "skill[name]", class: "agent-form__input", required: true) }
          field("Keywords") { input(type: "text", name: "skill[keywords]", class: "agent-form__input") }
          field("Description") { input(type: "text", name: "skill[description]", class: "agent-form__input") }
          field("Prompt") { textarea(name: "skill[prompt_body]", class: "agent-form__input agent-form__textarea") }
          div(class: "agent-form__actions") { button(type: "submit", class: "agent-form__btn") { "Create & Assign" } }
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
