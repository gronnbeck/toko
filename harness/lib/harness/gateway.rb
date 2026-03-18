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

      config.agent_tokens.each do |token|
        break if at_capacity?
        next unless within_budget?(token)

        tasks = client.fetch_pending_tasks(agent_token: token).fetch(:tasks, [])
        tasks.take(available_slots).each { |task| dispatch(task, token:) }
      end
    end

    def dispatch(task, token:)
      thread = Thread.new { AgentRunner.run(task:, client:, token:) }
      threads << thread
      threads.select!(&:alive?)
    end

    def within_budget?(token)
      result = client.check_budget(agent_token: token)
      result.fetch(:allowed, true)
    rescue StandardError
      true
    end

    def at_capacity? = threads.count(&:alive?) >= config.max_concurrent_agents
    def available_slots = config.max_concurrent_agents - threads.count(&:alive?)
  end
end
