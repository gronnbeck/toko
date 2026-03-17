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
      result = client.claim_task(task.fetch(:id), agent_token: token)
      return unless result[:status] == "claimed"

      output = execute(task)
      client.complete_task(task.fetch(:id), output:, agent_token: token)
    rescue => e
      client.fail_task(task.fetch(:id), error: e.message, agent_token: token)
      raise
    end

    private

    attr_reader :task, :client, :token

    def execute(task)
      # TODO: spawn the actual agent process
      raise NotImplementedError, "agent execution not yet implemented for task #{task[:id]}"
    end
  end
end
