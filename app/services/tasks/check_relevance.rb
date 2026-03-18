# frozen_string_literal: true

module Tasks
  module CheckRelevance
    module_function

    def call(task:, agent:, relevant:)
      digest = agent.mission_digest
      return { error: "Agent has no mission" } unless digest

      record = TaskRelevance.find_or_initialize_by(task: task, agent: agent)
      record.update!(relevant: relevant, mission_digest: digest)
      { status: "recorded", relevance: record }
    end
  end
end
