module Components
  class AgentSkillsSection < ApplicationComponent
    def initialize(agent:, available_skills:)
      @agent = agent
      @available_skills = available_skills
    end

    def view_template
      div(class: "skills-section") do
        h2(class: "skills-section__heading") { "Skills" }
        skills_list
        render ::Components::AgentSkillsForms.new(agent: @agent, available_skills: @available_skills)
      end
    end

    private

    def skills_list
      if @agent.skills.empty?
        p(class: "skills-section__empty") { "No skills assigned." }
        return
      end

      div(class: "skills-section__list") do
        @agent.agent_skills.includes(:skill).each { |as| skill_row(as) }
      end
    end

    def skill_row(agent_skill)
      skill = agent_skill.skill
      div(class: "skills-section__row") do
        div(class: "skills-section__info") do
          a(href: "/skills/#{skill.id}", class: "skills-section__name") { skill.name }
          span(class: "skills-section__keywords") { skill.keywords } if skill.keywords.present?
          span(class: "skills-section__desc") { skill.description } if skill.description.present?
        end
        remove_button(agent_skill)
      end
    end

    def remove_button(agent_skill)
      form(action: "/agents/#{@agent.id}/agent_skills/#{agent_skill.id}", method: "post", class: "skills-section__remove-form") do
        input(name: "_method", type: "hidden", value: "delete")
        input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
        button(type: "submit", class: "skills-section__remove-btn") { "Remove" }
      end
    end
  end
end
