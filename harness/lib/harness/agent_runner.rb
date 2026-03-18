# frozen_string_literal: true

module Harness
  class AgentRunner
    def self.run(task:, client:, token:)
      new(task:, client:, token:).run
    end

    def initialize(task:, client:, token:)
      @task   = task
      @client = client
      @token  = token
    end

    def run
      claim_result = client.claim_task(task_id, agent_token: token)
      return unless claim_result[:status] == "claimed"

      system_prompt = claim_result[:system_prompt]

      client.start_task(task_id, agent_token: token)
      output = execute(task, system_prompt:)
      client.post_result(task_id, body: output, agent_token: token) if output
      client.complete_task(task_id, agent_token: token)
    rescue => e
      client.fail_task(task_id, error: e.message, agent_token: token)
      raise
    end

    private

    attr_reader :task, :client, :token

    def task_id = task.fetch(:id)

    def execute(task, system_prompt:)
      # TODO: spawn the actual agent process with system_prompt
      warn "Agent execution not yet implemented (task #{task[:id]})"
      nil
    end
  end
end
