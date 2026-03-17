# frozen_string_literal: true

require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "valid with name and status" do
    agent = Agent.new(name: "Agent 1", status: :idle)
    assert agent.valid?
  end

  test "invalid without name" do
    agent = Agent.new(status: :idle)
    assert_not agent.valid?
  end

  test "status defaults to idle" do
    agent = Agent.create!(name: "Agent 1")
    assert agent.idle?
  end

  test "has expected statuses" do
    assert Agent.statuses.keys == %w[idle busy offline]
  end

  test "has one mission prompt" do
    agent = Agent.create!(name: "Agent 1")
    mission = Prompt.create!(body: "You are a helpful agent.", promptable: agent, kind: :mission)
    assert_equal mission, agent.mission
  end

  test "mission is destroyed with agent" do
    agent = Agent.create!(name: "Agent 1")
    Prompt.create!(body: "You are a helpful agent.", promptable: agent, kind: :mission)
    assert_difference "Prompt.count", -1 do
      agent.destroy
    end
  end

  test "belongs to an organization" do
    org = Organization.create!(name: "Acme")
    agent = Agent.create!(name: "Alpha", organization: org)
    assert_equal org, agent.organization
  end
end
