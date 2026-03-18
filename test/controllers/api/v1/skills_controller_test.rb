# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class SkillsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @agent = Agent.create!(name: "Coder")
        @skill = Skill.create!(name: "rails-conventions", keywords: "rails ruby", description: "Rails coding conventions")
        Prompt.create!(body: "Follow Rails conventions.", promptable: @skill, kind: :skill)
        AgentSkill.create!(agent: @agent, skill: @skill)
      end

      test "GET index returns skills for agent" do
        get api_v1_agent_skills_path(@agent.token), as: :json

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["skills"].size
        assert_equal "rails-conventions", body["skills"].first["name"]
        assert_equal "rails ruby", body["skills"].first["keywords"]
      end

      test "GET index returns 404 for unknown agent" do
        get api_v1_agent_skills_path("unknown-token"), as: :json
        assert_response :not_found
      end

      test "GET index excludes unassigned skills" do
        Skill.create!(name: "deployment", description: "Deploy stuff")
        get api_v1_agent_skills_path(@agent.token), as: :json

        assert_response :success
        names = response.parsed_body["skills"].map { |s| s["name"] }
        assert_includes names, "rails-conventions"
        assert_not_includes names, "deployment"
      end

      test "GET show returns skill with prompt" do
        get api_v1_agent_skill_path(@agent.token, "rails-conventions"), as: :json

        assert_response :success
        body = response.parsed_body["skill"]
        assert_equal "rails-conventions", body["name"]
        assert_equal "Follow Rails conventions.", body["prompt"]
      end

      test "GET show returns 404 for unassigned skill" do
        other = Skill.create!(name: "deployment", description: "Deploy stuff")
        get api_v1_agent_skill_path(@agent.token, other.name), as: :json
        assert_response :not_found
      end

      test "GET show returns 404 for unknown agent" do
        get api_v1_agent_skill_path("unknown-token", "rails-conventions"), as: :json
        assert_response :not_found
      end
    end
  end
end
