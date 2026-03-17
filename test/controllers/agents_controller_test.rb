# frozen_string_literal: true

require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = Agent.create!(name: "Alpha", description: "Does stuff")
  end

  test "GET show renders successfully" do
    get agent_path(@agent)
    assert_response :success
  end

  test "PATCH update changes agent attributes" do
    patch agent_path(@agent), params: { agent: { name: "Alpha Updated", description: "New description" } }
    assert_redirected_to agent_path(@agent)
    assert_equal "Alpha Updated", @agent.reload.name
    assert_equal "New description", @agent.reload.description
  end

  test "PATCH update creates mission prompt" do
    patch agent_path(@agent), params: { agent: { name: "Alpha", mission_body: "You are a helpful agent." } }
    assert_redirected_to agent_path(@agent)
    assert_equal "You are a helpful agent.", @agent.reload.mission.body
  end

  test "PATCH update updates existing mission prompt" do
    Prompt.create!(body: "Old mission.", promptable: @agent, kind: :mission)
    patch agent_path(@agent), params: { agent: { name: "Alpha", mission_body: "New mission." } }
    assert_equal "New mission.", @agent.reload.mission.body
  end

  test "PATCH update with invalid params re-renders show" do
    patch agent_path(@agent), params: { agent: { name: "" } }
    assert_response :unprocessable_entity
  end
end
