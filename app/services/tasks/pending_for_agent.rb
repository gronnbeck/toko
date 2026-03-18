# frozen_string_literal: true

module Tasks
  module PendingForAgent
    module_function

    def call(agent:)
      digest = agent.mission_digest

      scope = Task.where(status: :pending).order(created_at: :asc)
      return scope if digest.nil?

      irrelevant_ids = TaskRelevance
        .where(agent: agent, relevant: false, mission_digest: digest)
        .select(:task_id)

      scope.where.not(id: irrelevant_ids)
    end
  end
end
