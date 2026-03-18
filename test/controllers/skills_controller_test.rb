require "test_helper"

class SkillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @skill = Skill.create!(name: "ctrl-skill-#{SecureRandom.hex(4)}", keywords: "test", description: "Desc")
  end

  test "GET show renders successfully" do
    get skill_path(@skill)
    assert_response :success
  end

  test "PATCH update changes skill attributes" do
    patch skill_path(@skill), params: { skill: { name: @skill.name, keywords: "updated", description: "Updated" } }
    assert_redirected_to skill_path(@skill)
    assert_equal "updated", @skill.reload.keywords
  end

  test "PATCH update with invalid params re-renders show" do
    patch skill_path(@skill), params: { skill: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes skill and redirects" do
    agent = Agent.create!(name: "Alpha")
    AgentSkill.create!(agent:, skill: @skill)
    delete skill_path(@skill), params: { agent_id: agent.id }
    assert_redirected_to agent_path(agent)
    refute Skill.exists?(@skill.id)
    assert_equal 0, agent.agent_skills.count
  end

  test "DELETE destroy without agent_id redirects to agents index" do
    delete skill_path(@skill)
    assert_redirected_to agents_path
    refute Skill.exists?(@skill.id)
  end
end
