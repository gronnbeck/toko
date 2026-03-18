# frozen_string_literal: true

require "test_helper"

module Agents
  class BuildSystemPromptTest < ActiveSupport::TestCase
    test "includes org policy, mission, and CLI tools" do
      org = Organization.create!(name: "Acme")
      Prompt.create!(body: "Be safe.", promptable: org, kind: :policy)
      agent = Agent.create!(name: "Alpha", organization: org)
      Prompt.create!(body: "Run tests.", promptable: agent, kind: :mission)

      prompt = Agents::BuildSystemPrompt.call(agent: agent)

      assert_includes prompt, "Be safe."
      assert_includes prompt, "Run tests."
      assert_includes prompt, "tasks claim"
      assert_includes prompt, "tasks cost"
      assert_includes prompt, "goals list"
      assert_includes prompt, "goals activate"
      assert_includes prompt, "skills ls"
      assert_includes prompt, "skills load"
    end

    test "works without org or mission" do
      agent = Agent.create!(name: "Bravo")

      prompt = Agents::BuildSystemPrompt.call(agent: agent)

      assert_includes prompt, "tasks claim"
      assert_not_includes prompt, "Organization Policy"
      assert_not_includes prompt, "Your Mission"
    end

    test "works with mission but no org policy" do
      agent = Agent.create!(name: "Charlie")
      Prompt.create!(body: "Deploy code.", promptable: agent, kind: :mission)

      prompt = Agents::BuildSystemPrompt.call(agent: agent)

      assert_includes prompt, "Deploy code."
      assert_not_includes prompt, "Organization Policy"
    end
  end
end
