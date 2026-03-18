# frozen_string_literal: true

require_relative "test_helper"

module Harness
  class ExecutorTest < Minitest::Test
    FakeStatus = Struct.new(:exitstatus) do
      def success? = exitstatus == 0
    end

    def setup
      @task = { id: 1, title: "Fix the login bug", description: "Users can't log in" }
      @system_prompt = "You are a helpful agent."
      @server_url = "http://localhost:3360"
      @agent_token = "abc-123"
      @captured_cmd = nil
      @captured_env = nil
    end

    def test_returns_output_and_cost_from_json_response
      json = { result: "Fixed the bug", cost_usd: 0.42 }.to_json
      result = run_with(stdout: json, exit_code: 0)

      assert_equal "Fixed the bug", result[:output]
      assert_equal 42, result[:cost_cents]
    end

    def test_returns_raw_output_when_json_is_invalid
      result = run_with(stdout: "plain text output", exit_code: 0)

      assert_equal "plain text output", result[:output]
      assert_equal 0, result[:cost_cents]
    end

    def test_raises_on_nonzero_exit
      error = assert_raises(RuntimeError) do
        run_with(stdout: "", stderr: "something went wrong\n", exit_code: 1)
      end
      assert_match(/claude exited 1/, error.message)
    end

    def test_passes_system_prompt_file_to_claude
      run_with(stdout: { result: "ok" }.to_json, exit_code: 0)

      assert_includes @captured_cmd, "--system-prompt-file"
      prompt_path = @captured_cmd[@captured_cmd.index("--system-prompt-file") + 1]
      assert File.exist?(prompt_path) == false, "temp file should be cleaned up"
    end

    def test_passes_env_vars
      run_with(stdout: { result: "ok" }.to_json, exit_code: 0)

      assert_equal "http://localhost:3360", @captured_env["TOKO_URL"]
      assert_equal "abc-123", @captured_env["TOKO_AGENT_TOKEN"]
    end

    def test_task_prompt_includes_title_and_description
      run_with(stdout: { result: "ok" }.to_json, exit_code: 0)

      prompt = @captured_cmd.last
      assert_includes prompt, "Task: Fix the login bug"
      assert_includes prompt, "Users can't log in"
    end

    def test_task_prompt_includes_goal_title
      @task[:goal_title] = "Improve auth"
      run_with(stdout: { result: "ok" }.to_json, exit_code: 0)

      prompt = @captured_cmd.last
      assert_includes prompt, "Goal: Improve auth"
    end

    def test_handles_zero_cost
      result = run_with(stdout: { result: "Done", cost_usd: 0 }.to_json, exit_code: 0)
      assert_equal 0, result[:cost_cents]
    end

    private

    def run_with(stdout: "", stderr: "", exit_code: 0)
      fake_runner = lambda { |cmd, env|
        @captured_cmd = cmd
        @captured_env = env
        [ stdout, stderr, FakeStatus.new(exit_code) ]
      }

      Executor.new(
        task: @task,
        system_prompt: @system_prompt,
        server_url: @server_url,
        agent_token: @agent_token,
        runner: fake_runner
      ).call
    end
  end
end
