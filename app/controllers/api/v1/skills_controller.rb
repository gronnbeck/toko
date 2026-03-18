# frozen_string_literal: true

module Api
  module V1
    class SkillsController < Api::BaseController
      def index
        agent = Agent.find_by(token: params[:agent_token])
        return render json: { error: "Agent not found" }, status: :not_found unless agent

        skills = agent.skills.select(:name, :keywords, :description)
        render json: { skills: skills.map { |s| { name: s.name, keywords: s.keywords, description: s.description } } }
      end

      def show
        agent = Agent.find_by(token: params[:agent_token])
        return render json: { error: "Agent not found" }, status: :not_found unless agent

        skill = agent.skills.find_by(name: params[:name])
        return render json: { error: "Skill not found" }, status: :not_found unless skill

        render json: { skill: {
          name: skill.name, keywords: skill.keywords,
          description: skill.description, prompt: skill.prompt&.body
        } }
      end
    end
  end
end
