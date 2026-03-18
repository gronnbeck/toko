# frozen_string_literal: true

require "test_helper"

module Tasks
  class CreateTest < ActiveSupport::TestCase
    setup do
      @org = Organization.create!(name: "Acme")
      @goal = Goal.create!(title: "Ship v1", organization: @org)
      @agent = Agent.create!(name: "Planner", organization: @org)
    end

    test "creates a task linked to a goal" do
      task = Tasks::Create.call(goal: @goal, title: "Write tests", agent: @agent)

      assert task.persisted?
      assert_equal "Write tests", task.title
      assert_equal @goal, task.goal
      assert task.pending?
    end

    test "creates a task with description" do
      task = Tasks::Create.call(goal: @goal, title: "Write tests", description: "Cover edge cases", agent: @agent)

      assert task.persisted?
      assert_equal "Cover edge cases", task.description
    end

    test "returns invalid task without title" do
      task = Tasks::Create.call(goal: @goal, title: "", agent: @agent)

      assert_not task.persisted?
    end

    test "returns error when agent org does not match goal org" do
      other_org = Organization.create!(name: "Other")
      outsider = Agent.create!(name: "Outsider", organization: other_org)

      task = Tasks::Create.call(goal: @goal, title: "Nope", agent: outsider)

      assert_not task.persisted?
      assert_includes task.errors[:base], "Agent organization does not match goal organization"
    end
  end
end
