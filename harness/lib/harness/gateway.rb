# frozen_string_literal: true

module Harness
  class Gateway
    def self.start(config_path:)
      config = Config.load(config_path)
      new(config).run
    end

    def initialize(config)
      @config = config
      @client = ServerClient.new(config)
      @running_agents = []
    end

    def run
      loop do
        poll_and_dispatch
        sleep config.poll_interval_seconds
      end
    end

    private

    attr_reader :config, :client, :running_agents

    def poll_and_dispatch
      return if at_capacity?

      tasks = client.fetch_pending_tasks.fetch(:tasks, [])
      tasks.take(available_slots).each { |task| dispatch(task) }
    end

    def dispatch(task)
      thread = Thread.new { AgentRunner.run(task:, client:) }
      running_agents << thread
      running_agents.select!(&:alive?)
    end

    def at_capacity? = running_agents.count(&:alive?) >= config.max_concurrent_agents
    def available_slots = config.max_concurrent_agents - running_agents.count(&:alive?)
  end
end
