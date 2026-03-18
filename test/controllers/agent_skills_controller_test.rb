require "test_helper"

class AgentSkillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = Agent.create!(name: "Alpha")
    @skill = Skill.create!(name: "test-skill-#{SecureRandom.hex(4)}", keywords: "testing", description: "Test patterns")
  end

  test "POST create assigns existing skill to agent" do
    post agent_agent_skills_path(@agent), params: { skill_id: @skill.id }
    assert_redirected_to agent_path(@agent)
    assert_includes @agent.reload.skills, @skill
  end

  test "POST create with new skill creates and assigns" do
    skill_name = "brand-new-#{SecureRandom.hex(4)}"
    post agent_agent_skills_path(@agent), params: {
      skill: { name: skill_name, keywords: "new", description: "A new skill", prompt_body: "Do the thing" }
    }
    assert_redirected_to agent_path(@agent)
    created = Skill.find_by(name: skill_name)
    assert created
    assert_includes @agent.reload.skills, created
    assert_equal "Do the thing", created.prompt.body
  end

  test "POST create ignores duplicate assignment" do
    AgentSkill.create!(agent: @agent, skill: @skill)
    post agent_agent_skills_path(@agent), params: { skill_id: @skill.id }
    assert_redirected_to agent_path(@agent)
    assert_equal 1, @agent.agent_skills.where(skill: @skill).count
  end

  test "DELETE destroy removes assignment" do
    agent_skill = AgentSkill.create!(agent: @agent, skill: @skill)
    delete agent_agent_skill_path(@agent, agent_skill)
    assert_redirected_to agent_path(@agent)
    refute_includes @agent.reload.skills, @skill
  end
end
