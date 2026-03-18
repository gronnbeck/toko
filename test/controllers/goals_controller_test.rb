# frozen_string_literal: true

require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org = Organization.create!(name: "Acme")
    @goal = Goal.create!(title: "Ship v1", organization: @org)
  end

  test "GET index renders successfully" do
    get goals_path
    assert_response :success
  end

  test "GET new renders successfully" do
    get new_goal_path
    assert_response :success
  end

  test "POST create creates a goal" do
    assert_difference "Goal.count", 1 do
      post goals_path, params: { goal: { title: "Ship v2", description: "Go", organization_id: @org.id } }
    end
    assert_redirected_to goal_path(Goal.last)
  end

  test "POST create with invalid params re-renders new" do
    post goals_path, params: { goal: { title: "", organization_id: @org.id } }
    assert_response :unprocessable_entity
  end

  test "GET show renders successfully" do
    get goal_path(@goal)
    assert_response :success
  end

  test "GET edit renders successfully" do
    get edit_goal_path(@goal)
    assert_response :success
  end

  test "PATCH update changes goal" do
    patch goal_path(@goal), params: { goal: { title: "Ship v2", description: "Updated" } }
    assert_redirected_to goal_path(@goal)
    assert_equal "Ship v2", @goal.reload.title
  end

  test "PATCH update with invalid params re-renders edit" do
    patch goal_path(@goal), params: { goal: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes goal" do
    assert_difference "Goal.count", -1 do
      delete goal_path(@goal)
    end
    assert_redirected_to goals_path
  end

  test "POST transition changes status" do
    post transition_goal_path(@goal), params: { status: "active" }
    assert_redirected_to goal_path(@goal)
    assert @goal.reload.active?
  end
end
