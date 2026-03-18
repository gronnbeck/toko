# frozen_string_literal: true

require "open3"
require "tempfile"
require "json"

module Harness
  class Executor
    def self.call(task:, system_prompt:, server_url:, agent_token:)
      new(task:, system_prompt:, server_url:, agent_token:).call
    end

    def initialize(task:, system_prompt:, server_url:, agent_token:, runner: nil)
      @task = task
      @system_prompt = system_prompt
      @server_url = server_url
      @agent_token = agent_token
      @runner = runner || method(:default_runner)
    end

    def call
      prompt_file = write_system_prompt
      stdout, stderr, status = runner.call(build_command(prompt_file.path), build_env)

      unless status.success?
        raise "claude exited #{status.exitstatus}: #{stderr.lines.last&.strip}"
      end

      parse_output(stdout)
    ensure
      prompt_file&.close!
    end

    private

    attr_reader :task, :system_prompt, :server_url, :agent_token, :runner

    def write_system_prompt
      file = Tempfile.new([ "toko-prompt", ".txt" ])
      file.write(system_prompt)
      file.flush
      file
    end

    def build_command(prompt_path)
      [
        "claude", "-p",
        "--output-format", "json",
        "--system-prompt-file", prompt_path,
        "--allowedTools", "Bash", "Read", "Write", "Edit", "Glob", "Grep",
        "--dangerously-skip-permissions",
        task_prompt
      ]
    end

    def build_env
      { "TOKO_URL" => server_url, "TOKO_AGENT_TOKEN" => agent_token }
    end

    def default_runner(cmd, env)
      Open3.capture3(env, *cmd)
    end

    def task_prompt
      title = task.fetch(:title)
      description = task[:description]
      goal_title = task[:goal_title]

      parts = []
      parts << "Goal: #{goal_title}" if goal_title
      parts << "Task: #{title}"
      parts << description if description
      parts.join("\n\n")
    end

    def parse_output(stdout)
      data = JSON.parse(stdout, symbolize_names: true)
      cost_usd = data[:cost_usd] || 0
      cost_cents = (cost_usd * 100).round

      { output: data[:result], cost_cents: cost_cents }
    rescue JSON::ParserError
      { output: stdout, cost_cents: 0 }
    end
  end
end
