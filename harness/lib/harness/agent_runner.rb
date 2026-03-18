# frozen_string_literal: true

module Harness
  class AgentRunner
    def self.run(task:, client:, token:, executor: Executor)
      new(task:, client:, token:, executor:).run
    end

    def initialize(task:, client:, token:, executor: Executor)
      @task     = task
      @client   = client
      @token    = token
      @executor = executor
    end

    def run
      log "Claiming task #{task_id}"
      claim_result = client.claim_task(task_id, agent_token: token)
      return log("Could not claim task #{task_id}: #{claim_result[:error]}") unless claim_result[:status] == "claimed"

      log "Starting task #{task_id}"
      client.start_task(task_id, agent_token: token)
      result = execute(task, system_prompt: claim_result[:system_prompt])
      output = result&.fetch(:output, nil)
      cost_cents = result&.fetch(:cost_cents, nil)

      client.post_result(task_id, body: output, agent_token: token) if output
      client.complete_task(task_id, agent_token: token)
      log "Completed task #{task_id}"
      report_cost(cost_cents) if cost_cents
    rescue => e
      log "Task #{task_id} failed: #{e.message}"
      client.fail_task(task_id, error: e.message, agent_token: token)
      raise
    end

    private

    attr_reader :task, :client, :token, :executor

    def task_id = task.fetch(:id)

    def execute(task, system_prompt:)
      log "Executing task #{task_id}"
      executor.call(
        task:,
        system_prompt:,
        server_url: client.base_url,
        agent_token: token
      )
    end

    def report_cost(cost_cents)
      client.report_cost(task_id, cost_cents:, agent_token: token)
      log "Reported cost #{cost_cents}c for task #{task_id}"
    end

    def log(msg) = warn "[agent:#{token[0, 8]}] #{msg}"
  end
end
