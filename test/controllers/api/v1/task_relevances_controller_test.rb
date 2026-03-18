# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class TaskRelevancesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Alpha")
        Prompt.create!(body: "Run tests.", promptable: @agent, kind: :mission)
        @task = Task.create!(title: "Fix bug")
      end

      test "POST create records relevance" do
        post api_v1_task_relevance_path(@task),
             params: { agent_token: @agent.token, relevant: false }, as: :json

        assert_response :created
        assert_equal 1, TaskRelevance.count
        assert_not TaskRelevance.last.relevant
      end

      test "POST create returns 422 when agent has no mission" do
        agent = Agent.create!(name: "Bravo")

        post api_v1_task_relevance_path(@task),
             params: { agent_token: agent.token, relevant: true }, as: :json

        assert_response :unprocessable_entity
      end
    end
  end
end
