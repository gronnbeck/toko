# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class TasksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Alpha")
        @task  = Task.create!(title: "Fix bug", status: :pending)
      end

      test "GET index returns pending tasks" do
        get api_v1_tasks_path, as: :json
        assert_response :success
        tasks = response.parsed_body["tasks"]
        assert_includes tasks.map { |t| t["id"] }, @task.id
      end

      test "POST claim returns claimed" do
        post claim_api_v1_task_path(@task), params: { agent_token: @agent.token }, as: :json
        assert_response :success
        assert_equal "claimed", response.parsed_body["status"]
        assert_equal @agent.id, @task.reload.claimed_by_id
      end

      test "POST claim returns 409 when already claimed" do
        other = Agent.create!(name: "Bravo")
        @task.update!(status: :claimed, claimed_by: other)
        post claim_api_v1_task_path(@task), params: { agent_token: @agent.token }, as: :json
        assert_response :conflict
      end

      test "POST start transitions claimed to started" do
        @task.update!(status: :claimed, claimed_by: @agent)
        post start_api_v1_task_path(@task), params: { agent_token: @agent.token }, as: :json
        assert_response :success
        assert @task.reload.started?
      end

      test "POST start returns 422 when not claimed" do
        post start_api_v1_task_path(@task), params: { agent_token: @agent.token }, as: :json
        assert_response :unprocessable_entity
      end

      test "POST complete marks task completed" do
        @task.update!(status: :started, claimed_by: @agent)
        post complete_api_v1_task_path(@task), params: { agent_token: @agent.token }, as: :json
        assert_response :success
        assert @task.reload.completed?
      end

      test "POST fail marks task failed" do
        @task.update!(status: :started, claimed_by: @agent)
        post fail_api_v1_task_path(@task), params: { agent_token: @agent.token, error: "boom" }, as: :json
        assert_response :success
        assert @task.reload.failed?
      end

      test "GET index with agent_token filters out irrelevant tasks" do
        Prompt.create!(body: "Run tests.", promptable: @agent, kind: :mission)
        TaskRelevance.create!(
          task: @task, agent: @agent, relevant: false,
          mission_digest: @agent.mission_digest
        )

        get api_v1_tasks_path, params: { agent_token: @agent.token }, as: :json
        assert_response :success

        ids = response.parsed_body["tasks"].map { |t| t["id"] }
        assert_not_includes ids, @task.id
      end
    end
  end
end
