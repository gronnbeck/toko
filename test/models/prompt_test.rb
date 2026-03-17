# frozen_string_literal: true

require "test_helper"

class PromptTest < ActiveSupport::TestCase
  setup do
    @agent = Agent.create!(name: "Agent 1")
  end

  test "valid with body and agent" do
    prompt = Prompt.new(body: "You are a helpful agent.", agent: @agent)
    assert prompt.valid?
  end

  test "invalid without body" do
    prompt = Prompt.new(agent: @agent)
    assert_not prompt.valid?
  end

  test "invalid without agent" do
    prompt = Prompt.new(body: "You are a helpful agent.")
    assert_not prompt.valid?
  end
end
