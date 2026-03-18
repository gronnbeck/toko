# frozen_string_literal: true

require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "valid with name and status" do
    agent = Agent.new(name: "Agent 1", status: :online)
    assert agent.valid?
  end

  test "invalid without name" do
    agent = Agent.new(status: :online)
    assert_not agent.valid?
  end

  test "status defaults to offline" do
    agent = Agent.create!(name: "Agent 1")
    assert agent.offline?
  end

  test "token is auto-generated on create" do
    agent = Agent.create!(name: "Agent 1")
    assert_match(/\A[0-9a-f-]{36}\z/, agent.token)
  end

  test "token is unique" do
    a1 = Agent.create!(name: "Agent 1")
    a2 = Agent.create!(name: "Agent 2")
    assert_not_equal a1.token, a2.token
  end

  test "has expected statuses" do
    assert Agent.statuses.keys == %w[online busy missing offline]
  end

  test "display_status is online when pinged within 5 minutes" do
    agent = Agent.create!(name: "Agent 1", status: :online, last_seen_at: 1.minute.ago)
    assert_equal :online, agent.display_status
  end

  test "display_status is busy when busy and pinged within 5 minutes" do
    agent = Agent.create!(name: "Agent 1", status: :busy, last_seen_at: 1.minute.ago)
    assert_equal :busy, agent.display_status
  end

  test "display_status is missing when last ping was 5-10 minutes ago" do
    agent = Agent.create!(name: "Agent 1", status: :online, last_seen_at: 7.minutes.ago)
    assert_equal :missing, agent.display_status
  end

  test "display_status is offline when last ping was over 10 minutes ago" do
    agent = Agent.create!(name: "Agent 1", status: :online, last_seen_at: 11.minutes.ago)
    assert_equal :offline, agent.display_status
  end

  test "display_status is offline when never pinged" do
    agent = Agent.create!(name: "Agent 1")
    assert_equal :offline, agent.display_status
  end

  test "ping! updates last_seen_at" do
    agent = Agent.create!(name: "Agent 1")
    agent.ping!(status: :online)
    assert_in_delta Time.current, agent.reload.last_seen_at, 2
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

  test "mission_digest returns SHA256 of mission body" do
    agent = Agent.create!(name: "Agent 1")
    Prompt.create!(body: "Do testing work.", promptable: agent, kind: :mission)
    assert_equal Digest::SHA256.hexdigest("Do testing work."), agent.mission_digest
  end

  test "mission_digest is nil without a mission" do
    agent = Agent.create!(name: "Agent 1")
    assert_nil agent.mission_digest
  end

  test "daily_budget_cents is nil by default" do
    agent = Agent.create!(name: "Agent 1")
    assert_nil agent.daily_budget_cents
  end

  test "daily_budget_cents can be set" do
    agent = Agent.create!(name: "Agent 1", daily_budget_cents: 2000)
    assert_equal 2000, agent.daily_budget_cents
  end

  test "has many skills through agent_skills" do
    agent = Agent.create!(name: "Agent 1")
    skill = Skill.create!(name: "rails-conventions")
    AgentSkill.create!(agent: agent, skill: skill)
    assert_includes agent.skills, skill
  end

  test "destroying agent destroys agent_skills" do
    agent = Agent.create!(name: "Agent 1")
    skill = Skill.create!(name: "rails-conventions")
    AgentSkill.create!(agent: agent, skill: skill)
    assert_difference "AgentSkill.count", -1 do
      agent.destroy
    end
  end
end
