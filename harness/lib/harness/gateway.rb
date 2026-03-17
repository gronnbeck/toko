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
      @threads = []
    end

    def run
      Heartbeat.start(config:, client:)

      loop do
        poll_and_dispatch
        sleep config.poll_interval_seconds
      end
    end

    private

    attr_reader :config, :client, :threads

    def poll_and_dispatch
      return if at_capacity?

      tasks = client.fetch_pending_tasks.fetch(:tasks, [])
      tasks.take(available_slots).each do |task|
        token = config.agent_tokens.first
        dispatch(task, token:)
      end
    end

    def dispatch(task, token:)
      thread = Thread.new { AgentRunner.run(task:, client:, token:) }
      threads << thread
      threads.select!(&:alive?)
    end

    def at_capacity? = threads.count(&:alive?) >= config.max_concurrent_agents
    def available_slots = config.max_concurrent_agents - threads.count(&:alive?)
  end
end
