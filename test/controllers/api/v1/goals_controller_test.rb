# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class GoalsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @org = Organization.create!(name: "Acme")
        @goal = Goal.create!(title: "Ship v1", organization: @org)
      end

      test "GET index returns all goals" do
        get api_v1_goals_path, as: :json
        assert_response :success
        goals = response.parsed_body["goals"]
        assert_includes goals.map { |g| g["id"] }, @goal.id
      end

      test "GET index filters by organization_id" do
        other_org = Organization.create!(name: "Other")
        Goal.create!(title: "Other goal", organization: other_org)

        get api_v1_goals_path, params: { organization_id: @org.id }, as: :json
        assert_response :success
        goals = response.parsed_body["goals"]
        assert_equal 1, goals.size
        assert_equal @goal.id, goals.first["id"]
      end

      test "POST activate sets pending goal to active and creates planning task" do
        assert_difference "Task.count", 1 do
          post activate_api_v1_goal_path(@goal), as: :json
        end
        assert_response :success
        assert_equal "active", response.parsed_body["status"]
        assert @goal.reload.active?
        assert_equal "Plan goal: Ship v1", @goal.tasks.last.title
      end

      test "POST activate returns 422 if not pending" do
        @goal.update!(status: :active)
        post activate_api_v1_goal_path(@goal), as: :json
        assert_response :unprocessable_entity
      end
    end
  end
end
