# frozen_string_literal: true

module Harness
  class AgentRunner
    def self.run(task:, client:)
      new(task:, client:).run
    end

    def initialize(task:, client:)
      @task = task
      @client = client
    end

    def run
      client.claim_task(task.fetch(:id))
      output = spawn_agent(task)
      client.complete_task(task.fetch(:id), output:)
    rescue => e
      client.fail_task(task.fetch(:id), error: e.message)
      raise
    end

    private

    attr_reader :task, :client

    def spawn_agent(task)
      # TODO: spawn the actual agent process based on task configuration
      raise NotImplementedError, "agent spawning not yet implemented"
    end
  end
end
