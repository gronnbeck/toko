# frozen_string_literal: true

require "test_helper"

module Tasks
  class CheckRelevanceTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(name: "Alpha")
      Prompt.create!(body: "Run tests.", promptable: @agent, kind: :mission)
      @task = Task.create!(title: "Fix bug")
    end

    test "records a relevance check" do
      result = Tasks::CheckRelevance.call(task: @task, agent: @agent, relevant: false)

      assert_equal "recorded", result[:status]
      assert_not result[:relevance].relevant
      assert_equal @agent.mission_digest, result[:relevance].mission_digest
    end

    test "upserts on repeat call" do
      Tasks::CheckRelevance.call(task: @task, agent: @agent, relevant: false)
      Tasks::CheckRelevance.call(task: @task, agent: @agent, relevant: true)

      assert_equal 1, TaskRelevance.where(task: @task, agent: @agent).count
      assert TaskRelevance.find_by(task: @task, agent: @agent).relevant
    end

    test "returns error when agent has no mission" do
      agent = Agent.create!(name: "Bravo")

      result = Tasks::CheckRelevance.call(task: @task, agent: agent, relevant: true)

      assert_equal "Agent has no mission", result[:error]
    end
  end
end
