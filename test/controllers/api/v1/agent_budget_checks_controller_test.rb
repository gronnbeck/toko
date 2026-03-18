# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class AgentBudgetChecksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Alpha", daily_budget_cents: 1000)
      end

      test "GET show returns budget check result" do
        get api_v1_agent_budget_check_path(agent_token: @agent.token), as: :json
        assert_response :success
        body = response.parsed_body
        assert body["allowed"]
        assert_equal 0, body["spent_cents"]
        assert_equal 1000, body["limit_cents"]
      end

      test "GET show reflects spending" do
        Task.create!(title: "T1", status: :completed, claimed_by: @agent, cost_cents: 1000)
        get api_v1_agent_budget_check_path(agent_token: @agent.token), as: :json
        assert_response :success
        assert_not response.parsed_body["allowed"]
      end

      test "GET show without daily budget returns allowed" do
        agent = Agent.create!(name: "Bravo")
        get api_v1_agent_budget_check_path(agent_token: agent.token), as: :json
        assert_response :success
        assert response.parsed_body["allowed"]
      end
    end
  end
end
