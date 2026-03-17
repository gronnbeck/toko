# frozen_string_literal: true

require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "valid with name and status" do
    agent = Agent.new(name: "Agent 1", status: :idle)
    assert agent.valid?
  end

  test "invalid without name" do
    agent = Agent.new(status: :idle)
    assert_not agent.valid?
  end

  test "status defaults to idle" do
    agent = Agent.create!(name: "Agent 1")
    assert agent.idle?
  end

  test "has expected statuses" do
    assert Agent.statuses.keys == %w[idle busy offline]
  end
end
