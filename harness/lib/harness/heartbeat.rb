# frozen_string_literal: true

module Harness
  class Heartbeat
    def self.start(config:, client:)
      new(config:, client:).run
    end

    def initialize(config:, client:)
      @config = config
      @client = client
    end

    def run
      Thread.new do
        loop do
          ping_all
          sleep @config.ping_interval_seconds
        end
      end
    end

    private

    def ping_all
      @config.agent_tokens.each do |token|
        @client.ping_agent(token)
      rescue => e
        warn "Ping failed for #{token}: #{e.message}"
      end
    end
  end
end
