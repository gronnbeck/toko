# frozen_string_literal: true

require "test_helper"

class AgentSkillTest < ActiveSupport::TestCase
  test "valid with agent and skill" do
    agent = Agent.create!(name: "Coder")
    skill = Skill.create!(name: "rails-conventions")
    agent_skill = AgentSkill.new(agent: agent, skill: skill)
    assert agent_skill.valid?
  end

  test "invalid without agent" do
    skill = Skill.create!(name: "rails-conventions")
    agent_skill = AgentSkill.new(skill: skill)
    assert_not agent_skill.valid?
  end

  test "invalid without skill" do
    agent = Agent.create!(name: "Coder")
    agent_skill = AgentSkill.new(agent: agent)
    assert_not agent_skill.valid?
  end

  test "duplicate agent-skill pair is invalid" do
    agent = Agent.create!(name: "Coder")
    skill = Skill.create!(name: "rails-conventions")
    AgentSkill.create!(agent: agent, skill: skill)
    duplicate = AgentSkill.new(agent: agent, skill: skill)
    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end
end
