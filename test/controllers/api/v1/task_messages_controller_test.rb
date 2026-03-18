# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class TaskMessagesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Alpha")
        @task  = Task.create!(title: "Fix bug", status: :started, claimed_by: @agent)
      end

      test "GET index returns task messages" do
        @task.task_messages.create!(agent: @agent, body: "Working on it")

        get api_v1_task_messages_path(@task), as: :json
        assert_response :success

        messages = response.parsed_body["messages"]
        assert_equal 1, messages.size
        assert_equal "Working on it", messages.first["body"]
      end

      test "POST create posts a message" do
        post api_v1_task_messages_path(@task),
             params: { agent_token: @agent.token, body: "Progress update" }, as: :json

        assert_response :created
        assert_equal "created", response.parsed_body["status"]
        assert_equal 1, @task.task_messages.count
      end

      test "POST create posts a result message" do
        post api_v1_task_messages_path(@task),
             params: { agent_token: @agent.token, body: "Done", kind: "result" }, as: :json

        assert_response :created
        assert @task.task_messages.last.result?
      end

      test "POST create returns 422 when agent does not own task" do
        other = Agent.create!(name: "Bravo")

        post api_v1_task_messages_path(@task),
             params: { agent_token: other.token, body: "Hi" }, as: :json

        assert_response :unprocessable_entity
      end
    end
  end
end
