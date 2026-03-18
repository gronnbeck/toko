# frozen_string_literal: true

require "test_helper"

class SkillTest < ActiveSupport::TestCase
  test "valid with name" do
    skill = Skill.new(name: "rails-conventions")
    assert skill.valid?
  end

  test "invalid without name" do
    skill = Skill.new
    assert_not skill.valid?
  end

  test "name must be unique" do
    Skill.create!(name: "rails-conventions")
    duplicate = Skill.new(name: "rails-conventions")
    assert_not duplicate.valid?
  end

  test "has many agents through agent_skills" do
    skill = Skill.create!(name: "testing")
    agent = Agent.create!(name: "Coder")
    AgentSkill.create!(agent: agent, skill: skill)
    assert_includes skill.agents, agent
  end

  test "has one prompt" do
    skill = Skill.create!(name: "testing")
    prompt = Prompt.create!(body: "Follow TDD.", promptable: skill, kind: :skill)
    assert_equal prompt, skill.prompt
  end

  test "destroying skill destroys prompt" do
    skill = Skill.create!(name: "testing")
    Prompt.create!(body: "Follow TDD.", promptable: skill, kind: :skill)
    assert_difference "Prompt.count", -1 do
      skill.destroy
    end
  end

  test "destroying skill destroys agent_skills" do
    skill = Skill.create!(name: "testing")
    agent = Agent.create!(name: "Coder")
    AgentSkill.create!(agent: agent, skill: skill)
    assert_difference "AgentSkill.count", -1 do
      skill.destroy
    end
  end
end
