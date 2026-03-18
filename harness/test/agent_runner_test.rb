# frozen_string_literal: true

require_relative "test_helper"

module Harness
  class AgentRunnerTest < Minitest::Test
    def setup
      @token = "abc-123-def-456"
      @task = { id: 42, title: "Fix bug" }
      @client = FakeClient.new
      @executor = FakeExecutor.new
    end

    def test_full_lifecycle_claim_start_execute_complete
      run_agent

      assert_equal :claim, @client.calls[0][:action]
      assert_equal :start, @client.calls[1][:action]
      assert_equal :complete, @client.calls[2][:action]
    end

    def test_posts_result_when_execution_returns_output
      @executor.result = { output: "All done", cost_cents: 10 }
      run_agent

      result_call = @client.calls.find { |c| c[:action] == :post_result }
      assert result_call, "expected post_result call"
      assert_equal "All done", result_call[:body]
    end

    def test_reports_cost_when_present
      @executor.result = { output: "Done", cost_cents: 50 }
      run_agent

      cost_call = @client.calls.find { |c| c[:action] == :report_cost }
      assert cost_call, "expected report_cost call"
      assert_equal 50, cost_call[:cost_cents]
    end

    def test_skips_execution_on_claim_error
      @client.claim_response = { status: "error", error: "already claimed" }
      run_agent

      refute @client.calls.any? { |c| c[:action] == :start }
      refute @client.calls.any? { |c| c[:action] == :complete }
    end

    def test_fails_task_on_execution_error
      @executor.error = "process crashed"

      assert_raises(RuntimeError) { run_agent }

      fail_call = @client.calls.find { |c| c[:action] == :fail }
      assert fail_call, "expected fail_task call"
      assert_match(/process crashed/, fail_call[:error])
    end

    private

    def run_agent
      AgentRunner.run(task: @task, client: @client, token: @token, executor: @executor)
    end

    class FakeExecutor
      attr_accessor :result, :error

      def initialize
        @result = { output: nil, cost_cents: nil }
      end

      def call(**_args)
        raise error if error

        result
      end
    end

    class FakeClient
      attr_accessor :claim_response
      attr_reader :calls

      def initialize
        @calls = []
        @claim_response = { status: "claimed", system_prompt: "" }
      end

      def base_url = "http://localhost:3360"

      def claim_task(id, agent_token:)
        @calls << { action: :claim, id:, agent_token: }
        claim_response
      end

      def start_task(id, agent_token:)
        @calls << { action: :start, id:, agent_token: }
      end

      def complete_task(id, agent_token:)
        @calls << { action: :complete, id:, agent_token: }
      end

      def fail_task(id, error:, agent_token:)
        @calls << { action: :fail, id:, error:, agent_token: }
      end

      def post_result(id, body:, agent_token:)
        @calls << { action: :post_result, id:, body:, agent_token: }
      end

      def report_cost(id, cost_cents:, agent_token:)
        @calls << { action: :report_cost, id:, cost_cents:, agent_token: }
      end
    end
  end
end
