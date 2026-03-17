# frozen_string_literal: true

module Agents
  module Update
    module_function

    def call(agent:, params:)
      return false unless agent.update(name: params[:name], description: params[:description])

      upsert_mission(agent, params[:mission_body])
      true
    end

    def upsert_mission(agent, body)
      return if body.nil?

      existing = Prompt.find_by(promptable: agent, kind: :mission)

      if body.blank?
        existing&.destroy
      elsif existing
        existing.update!(body:)
      else
        Prompt.create!(body:, kind: :mission, promptable: agent)
      end
    end

    private_class_method :upsert_mission
  end
end
