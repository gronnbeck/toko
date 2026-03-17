# frozen_string_literal: true

require "yaml"

module Harness
  class Config
    attr_reader :server_url, :api_key, :poll_interval_seconds, :max_concurrent_agents

    def self.load(path)
      raw = YAML.safe_load(File.read(path), symbolize_names: true)
      new(raw)
    end

    def initialize(raw)
      @server_url = raw.fetch(:server_url)
      @api_key = raw.fetch(:api_key)
      @poll_interval_seconds = raw.fetch(:poll_interval_seconds, 5)
      @max_concurrent_agents = raw.dig(:agents, :max_concurrent) || 1
    end
  end
end
