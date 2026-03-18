# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid with name" do
    org = Organization.new(name: "Acme")
    assert org.valid?
  end

  test "invalid without name" do
    org = Organization.new
    assert_not org.valid?
  end

  test "has many agents" do
    org = Organization.create!(name: "Acme")
    agent = Agent.create!(name: "Alpha", organization: org)
    assert_includes org.agents, agent
  end

  test "agents are destroyed with organization" do
    org = Organization.create!(name: "Acme")
    Agent.create!(name: "Alpha", organization: org)
    assert_difference "Agent.count", -1 do
      org.destroy
    end
  end

  test "has one mission prompt" do
    org = Organization.create!(name: "Acme")
    mission = Prompt.create!(body: "We help customers.", promptable: org, kind: :mission)
    assert_equal mission, org.mission
  end

  test "has one policy prompt" do
    org = Organization.create!(name: "Acme")
    policy = Prompt.create!(body: "Always be polite.", promptable: org, kind: :policy)
    assert_equal policy, org.policy
  end

  test "has many goals" do
    org = Organization.create!(name: "Acme")
    goal = Goal.create!(title: "Ship v1", organization: org)
    assert_includes org.goals, goal
  end

  test "goals are destroyed with organization" do
    org = Organization.create!(name: "Acme")
    Goal.create!(title: "Ship v1", organization: org)
    assert_difference "Goal.count", -1 do
      org.destroy
    end
  end

  test "prompts are destroyed with organization" do
    org = Organization.create!(name: "Acme")
    Prompt.create!(body: "We help customers.", promptable: org, kind: :mission)
    assert_difference "Prompt.count", -1 do
      org.destroy
    end
  end
end
