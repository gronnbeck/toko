# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PingsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Alpha")
      end

      test "POST ping updates last_seen_at and status" do
        post api_v1_agent_ping_path(@agent.token),
          params: { status: "online" }, as: :json

        assert_response :success
        @agent.reload
        assert_in_delta Time.current, @agent.last_seen_at, 2
        assert @agent.online?
      end

      test "POST ping with busy status" do
        post api_v1_agent_ping_path(@agent.token),
          params: { status: "busy" }, as: :json

        assert_response :success
        assert @agent.reload.busy?
      end

      test "POST ping returns 404 for unknown token" do
        post api_v1_agent_ping_path("unknown-token"), as: :json
        assert_response :not_found
      end
    end
  end
end
